# Snowflake-Bigquery-Data-Migration

[![Automated Pipeline Deployment](https://github.com/AbhishekSingh1180/snowflake-bigquery-data-migration/actions/workflows/deploy.yaml/badge.svg)](https://github.com/AbhishekSingh1180/snowflake-bigquery-data-migration/actions/workflows/deploy.yaml)


## AIRFLOW DAG VIEW
![Diagram](https://github.com/AbhishekSingh1180/snowflake-bigquery-data-migration/blob/main/diagram/airflow-dag-view.png)

Leveraged GitHub Actions for streamlined GCP Pipeline deployment for Snowflake to BigQuery data migration. 
Using [sensex-data-analysis](https://github.com/AbhishekSingh1180/sensex-data-analysis) as source and snowflake storage integration feature to load data to GCS and workflow manangement/transformation using Composer(Airflow) and Dataflow.