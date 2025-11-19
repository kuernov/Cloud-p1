data "archive_file" "lambda_zip" {
    type        = "zip"
    source_dir  = "${path.module}/lambda_code"
    output_path = "${path.module}/lambda_package.zip"
}


########################################
# 2. Funkcja Lambda
########################################
resource "aws_lambda_function" "thumbnail_generator" {
  function_name = "${var.project}-thumbnail-generator-${var.env}"
  
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  # ↓↓↓ ZMIANA JEST TUTAJ ↓↓↓
  # Używamy ARN roli 'LabRole' zamiast tworzyć nową.
  role    = "arn:aws:iam::365165252715:role/LabRole"
    layers = ["arn:aws:lambda:us-east-1:770693421928:layer:Klayers-p311-Pillow:10"]  
    handler = "lambda_function.lambda_handler" 
  runtime = "python3.11" 
  
  timeout     = 30 
  memory_size = 256

}

########################################
# 3. Uprawnienie dla S3 do wywołania Lambda
########################################
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.thumbnail_generator.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.media.arn 
}

########################################
# 4. Wyzwalacz (Trigger) - Powiadomienie z S3
########################################
resource "aws_s3_bucket_notification" "s3_trigger" {
  bucket = aws_s3_bucket.media.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.thumbnail_generator.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3]
}