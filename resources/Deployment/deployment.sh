#!/bin/bash

FOLDER_PATH='resources/Storage/*'
BQ_SCHEMA_PATH='resources/Storage/BigQuery/bq_schema.json'

# Set project ID and region from Project Secrets
read -r PROJECT_NAME REGION <<< $(echo "$1" | tr ',' ' ')
# Set GCS Variables from GCS Secrets
read -r BUCKET_NAME GCS_SINK_FOLDER GCS_ARCHIVE_FOLDER <<< $(echo "$2" | tr ',' ' ')
# SET GCS iam policy Variables from GCS IAM Secrets
read -r CUSTOM_ROLE PERMISION_1 PERMISION_2 PERMISION_3  <<< $(echo "$3" | tr ',' ' ')
# Set BQ Variables from BQ Secrets
read -r DATASET_NAME TABLE_NAME <<< $(echo "$4" | tr ',' ' ')
# Set Region
gcloud config set compute/region $REGION

#----------------------------------------------------------------------------------------------------------

# # STEP 1 : Setup GCS bucket

# Create GCS bucket
gcloud storage buckets create gs://$BUCKET_NAME --project=$PROJECT_NAME  --location=$REGION --public-access-prevention --uniform-bucket-level-access 

# CP setup files to GCS bucket
gcloud storage cp -r $FOLDER_PATH gs://$BUCKET_NAME/
echo "$(date) - SINK" | gcloud storage cp - gs://$BUCKET_NAME/$GCS_SINK_FOLDER/init.txt 
echo "$(date) - ARCHIVE" | gcloud storage cp - gs://$BUCKET_NAME/$GCS_ARCHIVE_FOLDER/init.txt 

#----------------------------------------------------------------------------------------------------------

# STEP 2 : Setup storage integration for snowflake out stage to GCS for file transfering

# CREATE_STORAGE_INT
~/bin/snowsql --config ~/.snowsql/config --connection awesome -w "COMPUTE_WH" -q "CREATE STORAGE INTEGRATION GCS_STORAGE_INT TYPE = EXTERNAL_STAGE STORAGE_PROVIDER = 'GCS' ENABLED = TRUE STORAGE_ALLOWED_LOCATIONS = ('gcs://$BUCKET_NAME/$GCS_SINK_FOLDER/');" 
# CREATE_OUT_STAGE
~/bin/snowsql --config ~/.snowsql/config --connection awesome -w "COMPUTE_WH" -q "CREATE STAGE FINANCE_DB.DW_APPL.SENSEX_DATA_STAGE_OUT URL = 'gcs://$BUCKET_NAME/$GCS_SINK_FOLDER/' STORAGE_INTEGRATION = GCS_STORAGE_INT FILE_FORMAT = (TYPE = CSV SKIP_HEADER = 1);" 

# Retrieve service account
SNF_SERVICE_ACCOUNT=$(~/bin/snowsql --config ~/.snowsql/config --connection awesome -w "COMPUTE_WH" -q "DESC STORAGE INTEGRATION GCS_STORAGE_INT" -o output_format=csv -o header=false | awk 'NR==7' | cut -d',' -f3 | tr -d '"' )

gcloud storage buckets add-iam-policy-binding gs://$BUCKET_NAME --member=serviceAccount:$SNF_SERVICE_ACCOUNT --role=projects/$PROJECT_NAME/roles/$CUSTOM_ROLE --project=$PROJECT_NAME 

#----------------------------------------------------------------------------------------------------------

# STEP 3 : Setup BigQuery Dataset and table
gcloud alpha bq datasets create $DATASET_NAME --project=$PROJECT_NAME --quiet
gcloud alpha bq tables create $TABLE_NAME --dataset=$DATASET_NAME --description 'Sink table' --schema-file=$BQ_SCHEMA_PATH --quiet --project=$PROJECT_NAME --overwrite

#----------------------------------------------------------------------------------------------------------