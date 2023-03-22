# Piperider
# conda activate capital_bike; source setup/run_piperider.sh data_modelling init

set -e

DEV_BRANCH=$1
TASK=$2

source ./.env

export PYTHONPATH="${HOME}/private/prefect:${PYTHONPATH}"
export DATASET_NAME=${DATASET_NAME}
export GCP_CREDENTIALS=${GCP_CREDENTIALS}
export GCP_PROJECT_ID=${GCP_PROJECT_ID}

cd ~/${PROJECT_FOLDER}/prefect/${DATASET_NAME}


if [ ${TASK} == 'init' ]; then
    echo "First Time Run"
    git switch -c ${DEV_BRANCH}
    dbt deps
    dbt build
    piperider init
    piperider diagnose
    piperider run
elif [ ${TASK} == 'compare-reports' ]; then
    echo "Compare the data models"
    git checkout ${DEV_BRANCH}
    dbt deps
    dbt compile
    dbt build
    piperider run
    piperider compare-reports --last
else
    echo "Please retry and edit the command"
fi

cd ../..