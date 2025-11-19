import boto3
import os
from PIL import Image
from io import BytesIO

s3_client = boto3.client('s3')
THUMBNAIL_SIZE = (200, 200) # Rozmiar miniaturki

def lambda_handler(event, context):
    
    # 1. Odczytaj bucket i klucz (nazwę pliku) z eventu S3
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = event['Records'][0]['s3']['object']['key']
    
    # WAŻNE: Unikaj nieskończonej pętli!
    # Jeśli plik jest już w folderze thumbnails, nie rób nic.
    if "thumbnails/" in key:
        print("This is already a thumbnail. Exiting.")
        return
        
    print(f"Generating thumbnail for: s3://{bucket}/{key}")

    try:
        # 2. Pobierz oryginalny obrazek z S3
        response = s3_client.get_object(Bucket=bucket, Key=key)
        image_data = response['Body'].read()
        
        # 3. Użyj Pillow do stworzenia miniaturki
        img = Image.open(BytesIO(image_data))
        img.thumbnail(THUMBNAIL_SIZE)
        
        # Przygotuj do zapisu
        out_buffer = BytesIO()
        # Musimy zapisać jako JPEG lub PNG. Użyjmy formatu oryginału.
        img_format = img.format if img.format in ['JPEG', 'PNG'] else 'JPEG'
        img.save(out_buffer, format=img_format)
        out_buffer.seek(0)

        # 4. Wyślij miniaturkę z powrotem do S3
        # Zapisz w folderze 'thumbnails/' z tą samą nazwą
        thumb_key = f"thumbnails/{os.path.basename(key)}"
        
        s3_client.put_object(
            Bucket=bucket,
            Key=thumb_key,
            Body=out_buffer,
            ContentType=f'image/{img_format.lower()}'
        )
        
        print(f"Successfully created thumbnail: s3://{bucket}/{thumb_key}")
        return {'status': 200, 'key': thumb_key}
        
    except Exception as e:
        print(f"Error processing image {key}: {e}")
        raise e