#!/bin/bash

$FOLDER_PATH = 'resources/Storage/apcha.csv'

# Set project ID and region from Project Secrets
read -r PROJECT_NAME REGION <<< $(echo "$1" | tr ',' ' ')

# Set default project and region
gcloud config set project $PROJECT_NAME
gcloud config set compute/region $REGION

# Set GCS Variables from GCS Secrets
read -r BUCKET_NAME GCS_FOLDER <<< $(echo "$2" | tr ',' ' ')

# Create GCS bucket
gsutil mb gs://$BUCKET_NAME

# cp local folder to GCS bucket
gsutil -m cp -r $FOLDER_PATH gs://$BUCKET_NAME/$GCS_FOLDER