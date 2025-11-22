#!/bin/bash
set -e  # zatrzymaj skrypt jeśli coś pójdzie nie tak

# --- KONFIGURACJA ---
AWS_REGION="us-east-1"                     # Twój region
BACKEND_REPO_NAME="myapp-backend-dev"
FRONTEND_REPO_NAME="myapp-frontend-dev"
TAG="latest"

TERRAFORM_DIR="./terraform"                # katalog z Terraform
BACKEND_DIR="./backend"
FRONTEND_DIR="./frontend"

echo "🚀 Rozpoczynam setup infrastruktury i deployment..."

# 1. Pobranie ID konta AWS dynamicznie (bezpieczniej niż hardcode)
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "ℹ️  Zalogowano jako konto: $AWS_ACCOUNT_ID w regionie $AWS_REGION"

# 2. Uruchomienie Terraform (tylko ECR i Cognito)
echo "--------------------------------------------------"
echo "🏗️  Tworzenie ECR i Cognito przez Terraform..."
echo "--------------------------------------------------"

cd $TERRAFORM_DIR

# Inicjalizacja (jeśli jeszcze nie była robiona)
terraform init

# Apply z flagą -auto-approve (żeby nie pytał o 'yes')
# UWAGA: Sprawdź czy nazwy zasobów (po kropce) zgadzają się z Twoim plikiem .tf!
# W poprzednim przykładzie używaliśmy 'main' dla poola i 'client' dla klienta.
terraform apply \
  -target=aws_ecr_repository.backend \
  -target=aws_ecr_repository.frontend \
  -target=aws_cognito_user_pool.user_pool \
  -target=aws_cognito_user_pool_client.app_client \
  -auto-approve

cd ..

# 3. Logowanie do ECR
echo "--------------------------------------------------"
echo "🔑 Logowanie do ECR..."
echo "--------------------------------------------------"
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"

# 4. Budowanie i Pushowanie BACKENDU
echo "--------------------------------------------------"
echo "🐳 Backend: Budowanie i Pushowanie..."
echo "--------------------------------------------------"

# --platform linux/amd64 jest kluczowe dla kompatybilności z Fargate, jeśli budujesz na Mac M1/M2/M3
docker build --platform linux/amd64 -t $BACKEND_REPO_NAME $BACKEND_DIR

BACKEND_FULL_TAG="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$BACKEND_REPO_NAME:$TAG"
docker tag $BACKEND_REPO_NAME:latest $BACKEND_FULL_TAG
docker push $BACKEND_FULL_TAG

# 5. Budowanie i Pushowanie FRONTENDU
echo "--------------------------------------------------"
echo "🐳 Frontend: Budowanie i Pushowanie..."
echo "--------------------------------------------------"

# Tutaj też wymuszamy platformę linux/amd64
docker build --platform linux/amd64 -t $FRONTEND_REPO_NAME $FRONTEND_DIR

FRONTEND_FULL_TAG="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$FRONTEND_REPO_NAME:$TAG"
docker tag $FRONTEND_REPO_NAME:latest $FRONTEND_FULL_TAG
docker push $FRONTEND_FULL_TAG

echo "--------------------------------------------------"
echo "✅ SUKCES! Obrazy są w ECR, a Cognito gotowe."
echo "   Teraz możesz uruchomić 'terraform apply' (bez targetów), aby postawić ECS."
echo "--------------------------------------------------"
echo "✅ Obrazy wypchnięte do ECR!"
cd $TERRAFORM_DIR
terraform apply -auto-approve