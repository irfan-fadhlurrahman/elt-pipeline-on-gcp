import os
import ast
import json

from prefect_gcp import GcpCredentials
from prefect_gcp.cloud_storage import GcsBucket
from prefect.filesystems import GCS
from prefect_gcp.bigquery import BigQueryWarehouse
from prefect.infrastructure.process import Process
from prefect.infrastructure.docker import DockerContainer

from dotenv import load_dotenv
load_dotenv()

# Load global variables from .env file
ENV_VARIABLES_LIST = [
    "SERVICE_ACC_PATH", "GCP_PROJECT_ID", "GCP_CREDENTIALS", 
    "GCP_REGION", "GCP_ZONE", "DATASET_NAME", "DATASET_LOCATION",
    "BUCKET_NAME", "CREDENTIALS_BLOCK", "BUCKET_BLOCK", "DOCKER_BLOCK",
    "BQ_BLOCK", "DBT_PROFILES_DIR", "INFRA_BLOCK"
]
env_dict = {}
for variable in ENV_VARIABLES_LIST:
    env_dict[variable] = os.environ.get(variable)

# Read Service Account
with open(env_dict["SERVICE_ACC_PATH"], 'r') as f:
    gcp_service_acc = json.load(f)

# Create Blocks
process_block = Process(
    env=env_dict, 
    name="local_deployment"
)
process_block.save(env_dict["INFRA_BLOCK"], overwrite=True)

credentials_block = GcpCredentials(
    service_account_info=gcp_service_acc
)
credentials_block.save(env_dict["CREDENTIALS_BLOCK"], overwrite=True)

bucket_block = GcsBucket(
    gcp_credentials=GcpCredentials.load(env_dict["CREDENTIALS_BLOCK"]), 
    bucket=env_dict["BUCKET_NAME"]
)
bucket_block.save(env_dict["BUCKET_BLOCK"], overwrite=True)

bigquery_block = BigQueryWarehouse(
    gcp_credentials=GcpCredentials.load(env_dict["CREDENTIALS_BLOCK"])
)
bigquery_block.save(env_dict["BQ_BLOCK"], overwrite=True)

docker_block = DockerContainer(
    image="irfanfadh43/prefect:elt_pipeline",
    image_pull_policy="ALWAYS",
    auto_remove=True,
    env=env_dict,
    command=['python', '-m', 'prefect.engine']
)
docker_block.save(env_dict["DOCKER_BLOCK"], overwrite=True)