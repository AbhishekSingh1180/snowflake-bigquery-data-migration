#!/bin/bash

FOLDER_PATH = 'resources/Storage/apcha.csv'

# Set project ID and region from Project Secrets
read -r PROJECT_NAME REGION <<< $(echo "$1" | tr ',' ' ')

# Set GCS Variables from GCS Secrets
read -r BUCKET_NAME GCS_FOLDER <<< $(echo "$2" | tr ',' ' ')

# Create GCS bucket
gcloud storage buckets create gs://$BUCKET_NAME --project=$PROJECT_NAME --location=$REGION --no-public-access-prevention --no-uniform-bucket-level-access

# cp local folder to GCS bucket
gcloud storage cp $FOLDER_PATH gs://$BUCKET_NAME/$GCS_FOLDER