# https://docs.prefect.io/tutorials/docker/

export PYTHONPATH="${HOME}/private/prefect:${PYTHONPATH}"
export DATASET_NAME=${DATASET_NAME}
export GCP_CREDENTIALS=${GCP_CREDENTIALS}
export GCP_PROJECT_ID=${GCP_PROJECT_ID}

prefect deployment build \
    --infra-block docker-container/docker-block \
    --pool default-agent-pool \
    --name "batch-elt-pipeline-using-docker" \
    --output ./deployments/batch-elt-pipeline-using-docker_deployment.yaml \
    --param "start_date=2021/01/01" \
    --param "end_date=2023/01/31" \
    ./flows/local_to_gcs.py:local_to_gcs_parent_flow -a

prefect deployment run 'local-to-gcs-parent-flow/batch-elt-pipeline-using-docker'

prefect agent start --pool default-agent-pool --work-queue default    