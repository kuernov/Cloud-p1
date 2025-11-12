#!/bin/bash
set -e  # zatrzymaj skrypt jeśli coś pójdzie nie tak

# --- KONFIGURACJA ---
AWS_REGION="us-east-1"           # zmień na swój region
BACKEND_REPO_NAME="myapp-backend-dev"         # nazwa repo w ECR
FRONTEND_REPO_NAME="myapp-frontend-dev"
TAG="latest" 

# --- LOGOWANIE DO ECR ---
echo "Logowanie do ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin 365165252715.dkr.ecr.$AWS_REGION.amazonaws.com

# --- BACKEND ---
echo "Budowanie obrazu backend..."
docker build -t $BACKEND_REPO_NAME ./backend

BACKEND_FULL_TAG="365165252715.dkr.ecr.$AWS_REGION.amazonaws.com/$BACKEND_REPO_NAME:$TAG"
echo "Tagowanie backend obrazu: $BACKEND_FULL_TAG"
docker tag $BACKEND_REPO_NAME:latest $BACKEND_FULL_TAG

echo "Wypychanie backend obrazu..."
docker push $BACKEND_FULL_TAG

# --- FRONTEND ---
echo "Budowanie obrazu frontend..."
docker build -t $FRONTEND_REPO_NAME ./frontend

FRONTEND_FULL_TAG="365165252715.dkr.ecr.$AWS_REGION.amazonaws.com/$FRONTEND_REPO_NAME:$TAG"
echo "Tagowanie frontend obrazu: $FRONTEND_FULL_TAG"
docker tag $FRONTEND_REPO_NAME:latest $FRONTEND_FULL_TAG

echo "Wypychanie frontend obrazu..."
docker push $FRONTEND_FULL_TAG

echo "✅ Obrazy wypchnięte do ECR!"