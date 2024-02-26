# Snowflake-Bigquery-Data-Migration

[![Automated Pipeline Deployment](https://github.com/AbhishekSingh1180/snowflake-bigquery-data-migration/actions/workflows/deploy.yaml/badge.svg)](https://github.com/AbhishekSingh1180/snowflake-bigquery-data-migration/actions/workflows/deploy.yaml)

![Diagram](https://github.com/AbhishekSingh1180/snowflake-bigquery-data-migration/blob/main/diagram/snf-bq-migration.png)

## AIRFLOW DAG VIEW
![Diagram](https://github.com/AbhishekSingh1180/snowflake-bigquery-data-migration/blob/main/diagram/airflow-dag-view.png)

Leveraged GitHub Actions to automate the deployment of a GCP pipeline for Snowflake to BigQuery data migration. Utilized [sensex-data-analysis](https://github.com/AbhishekSingh1180/sensex-data-analysis) as the data source and Snowflake storage integration feature to load data to GCS. Implemented workflow management and transformation using Composer (Airflow) and Dataflow