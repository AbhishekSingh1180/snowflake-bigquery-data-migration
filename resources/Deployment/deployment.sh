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

EXECUTE_SQL_SCRIPT="execute.sql" 

echo "CREATE STORAGE INTEGRATION GCS_STORAGE_INT \
  TYPE = EXTERNAL_STAGE \
  STORAGE_PROVIDER = 'GCS' \
  ENABLED = TRUE \
  STORAGE_ALLOWED_LOCATIONS = ('gcs://$BUCKET_NAME/$GCS_SINK_FOLDER/');" 
>> $EXECUTE_SQL_SCRIPT

echo "CREATE STAGE FINANCE_DB.DW_APPL.SENSEX_DATA_STAGE_OUT \
  URL = 'gcs://$BUCKET_NAME/$GCS_SINK_FOLDER/' \
  STORAGE_INTEGRATION = GCS_STORAGE_INT \
  FILE_FORMAT = (TYPE = CSV SKIP_HEADER = 1);"
>> $EXECUTE_SQL_SCRIPT

~/bin/snowsql --config ~/.snowsql/config --connection awesome -w "COMPUTE_WH" -f $EXECUTE_SQL_SCRIPT 
rm -rf $EXECUTE_SQL_SCRIPT

# Retrieve service account
SNF_SERVICE_ACCOUNT=$(~/bin/snowsql --config ~/.snowsql/config --connection awesome -w "COMPUTE_WH" -q "DESC STORAGE INTEGRATION GCS_STORAGE_INT" \
-o output_format=csv -o header=false | awk 'NR==7' | cut -d',' -f3 | tr -d '"' )

gcloud iam roles create $CUSTOM_ROLE /
    --project=$PROJECT_NAME /
    --title="Custom Snowflake GCS Writer" /
    --description="Custom role with minimal permissions for Snowflake to load data into GCS" /
    --permissions=$PERMISION_1,$PERMISION_2,$PERMISION_3

#
gcloud storage buckets add-iam-policy-binding gs://$BUCKET_NAME --member=serviceAccount:$SNF_SERVICE_ACCOUNT --role=projects/$PROJECT_NAME/roles/$CUSTOM_ROLE --project=$PROJECT_NAME 

#----------------------------------------------------------------------------------------------------------

# STEP 3 : Setup BigQuery Dataset and table
bq --location=$REGION mk -t $PROJECT_NAME:$DATASET_NAME
bq --location=$REGION mk -t $PROJECT_NAME:$DATASET_NAME.$TABLE_NAME $BQ_SCHEMA_PATH

#----------------------------------------------------------------------------------------------------------