# Data Engineering Zoomcamp Final Project

## Problem Description
The aim of this project is to apply data engineering concepts and tools that have been learned on a [Data Engineering Zoomcamp](https://github.com/DataTalksClub/data-engineering-zoomcamp) course including data visualization to get insight from the preprocessed data.

The end goal is to create a dashboard that answers the following questions.
* Which hour of the day has the most active members to use the bike?
* What are the most popular start and end station pairings?
* What are the number of rides and average durations by day of week?
* Which bikes have been ridden the most?

This is a batch orchestration project. It uses extract, load and transform (ELT) approach where the data is loaded to target data warehouse (DWH) then transform it within DWH before creating a dashboard.  

The dataset to use is [Capital Bike Share](https://s3.amazonaws.com/capitalbikeshare-data/index.html) dataset from January 2021 to January 2023 with around 6 million trip records and 13 fields. It is spread into multiple files as a .zip file in the S3 public bucket. This dataset contains a timestamp and station location for both departure and arrival.

## Tech Stacks
For this project, the following are the tools to build end-to-end data pipeline:
* **Terraform**: To enable data infrastructures such as a virtual machine, data lake storage and data warehouse in Google Cloud Platform.
* **Google Cloud Storage**: To store raw data for building a data lake. 
* **Google BigQuery**: To store preprocessed data in the warehouse for creating a dashboard.
* **Google Compute Engine**: To host a virtual machine for developing this project.
* **Prefect**: To orchestrate a data pipeline which is from collecting raw data to load & transform the data within a data warehouse.
* **Docker**: To containerize the data pipeline deployment.
* **dbt**: To transform the raw data into clean one within the data warehouse.
* **PipeRider**: To track the changes in the data warehouse by inspecting the statistics of each field.
* **Metabase**: To create a dashboard to answer above questions.

## Data Pipeline
The end-to-end pipeline steps as follows:

1. Convert all dataset into parquet files by using Vaex library in python to ensure each dataset column has a uniform data type. The data type should not be fully correct at these steps.
2. Upload parquet files to Google Cloud Storage (GCS).
3. Create an External Table in BigQuery by using dataset files in the GCS.
4. Transform the external table as per data model using dbt to create a table and a view in the data warehouse for a dashboard creation. The fact table is partitioned by arrival timestamp and clustered by bike types.
5. Inspect data quality using PipeRider then refine the SQL query in the dbt models if needed, and create a dashboard that answers all questions in the Problem Description section.

All above steps are orchestrated by using Prefect. For step 4, use dbt to transform raw data into refined one. To check data quality in the data warehouse, use Piperider to check the data profile of each field in the table. If there are any quality issues, go back to the dbt query to retransform the data then compare the change in the Piperider.

## Data Quality
There are two aspects to consider when checking data quality in the warehouse such as.
1. Uniqueness of primary key which is ride id for this project.
2. Missing values on the station field for both departure and arrival.

To demonstrate data changes in the fact table at a warehouse, remove all missing values on the both trip route where is a pair of station start & end.

![alt text](https://github.com/irfan-fadhlurrahman/dtc-de-final-project/blob/main/images/1_ride_id.PNG "source: Author personal image")

![alt text](https://github.com/irfan-fadhlurrahman/dtc-de-final-project/blob/main/images/2_trip_route.PNG "source: Author personal image")

The removed missing values of the station field are around three hundred thousand rows and the uniqueness of the ride id are the same for both data models. 

## Dashboard
This dashboard uses the latest data model which contains no missing values in the station-related field. 

![alt text](https://github.com/irfan-fadhlurrahman/dtc-de-final-project/blob/main/images/Dashboard.gif "Capital Bike Dashboard | source: Author personal image")

From the above dashboard, we can conclude that the most active members are at 17.00 to 18.00 where it is the time range for most people to go home after working. Also, notice that around 08.00 there is a peak too for members. But, the highest total trips per day of week are at weekends with average trip duration more than 25 minutes. The top eight of station pairings have the same start and end station name. It means that some of the users ride the bike not to go to other places. The classic bike still dominates with 83% shares. 

## Reproducibility
To run this project on other environment, clone this repo
```bash
git clone https://github.com/irfan-fadhlurrahman/dtc-de-final-project.git
``` 

and prepare the following items or tools such as
1. Google Cloud Account
2. SSH keys
3. Google Cloud Service Account with IAM policy as follows
    * BigQuery Admin
    * Storage Admin
    * Storage Transfer Admin
    * Compute Admin
    * Viewer
4. Python (v.3.9.16)
5. Terraform (v1.3.7)
6. Docker (v20.10.2)
7. Prefect (v2.8.5)
8. dbt (v1.4.5)
9. PipeRider (v0.21)

Second, edit or create the .env file as per your environment. Some of the variables need to be edited.
```bash
# General
USER=vm-username
PROJECT_FOLDER=your-project-folder-in-vm

# GCP
GCP_PROJECT_ID=your-project-id
GCP_CREDENTIALS=/.google/credentials/google_credentials.json
GCP_REGION=your-region
GCP_ZONE=your-region
DATASET_NAME=capital_bike_share
DATASET_LOCATION=US
BUCKET_NAME=${GCP_PROJECT_ID}_${DATASET_NAME}

# Prefect
SERVICE_ACC_PATH="${HOME}${GCP_CREDENTIALS}"
CREDENTIALS_BLOCK=gcp-credentials
BUCKET_BLOCK=gcp-bucket
BQ_BLOCK=gcp-bq
INFRA_BLOCK=env-variables
DOCKER_BLOCK=docker-block
```

Third, run all necessary resources for this project via Terraform using this command below. Do not forget to create ssh keys and upload to metadata in Compute Engine.
```bash
source ../.env
cd ~/${PROJECT_FOLDER}/terraform
export TF_VAR_project_id="${GCP_PROJECT_ID}" 
export TF_VAR_credentials="${GCP_CREDENTIALS}" 
export TF_VAR_region="${GCP_REGION}" 
export TF_VAR_zone="${GCP_ZONE}"
export TF_VAR_dataset_name="${DATASET_NAME}"
export TF_VAR_dataset_location="${DATASET_LOCATION}"

terraform init
terraform validate
terraform fmt
terraform plan
terraform apply -auto-approve
```
If the virtual machine is unable to apply, just re-run the above code.

Fourth, open the virtual machine via SSH. Then, go to ‘setup’ folder to install all dependencies for this project.
```bash
source setup/install_docker.sh && \
source setup/install_miniconda.sh && \
sudo reboot
```

After rebooting, run Metabase container
```bash
source setup/run_metabase.sh
```

Ensure the python 3.9.16 and Docker installed then prepare requirements.txt and create a Python virtual environment. Here are libraries that used in this project.
```bash
prefect==2.8.5
prefect-sqlalchemy==0.2.4
prefect-gcp[cloud_storage]
prefect-gcp[bigquery]
prefect-gcp[secret_manager]
prefect-dbt[bigquery]
protobuf==4.22.1
pyarrow==6.0.1
python-dotenv
psycopg2-binary==2.9.5
sqlalchemy==1.4.46
vaex==4.16.0
dbt-core==1.4.5
dbt-bigquery==1.4.3
piperider[bigquery]
pybigquery==0.10.2
```

Fifth, install a virtual environment.
```bash
conda create -n capital_bike python=3.9 -y
conda activate capital_bike
pip install -r requirements.txt
```
Go to `prefect/capital_bike_share/fact_bike_tripdata.sql` to comment `AND trip_route IS NOT NULL` before build a pipeline container.

Sixth, before running end-to-end pipeline, prepare its docker image and push it to docker hub.
```bash
DOCKER_HUB_USERNAME=your-docker-hub-username
docker login
docker build -t ${DOCKER_HUB_USERNAME}/prefect:elt_pipeline .
docker image push ${DOCKER_HUB_USERNAME}/prefect:elt_pipeline
```

To use local deploy and PipeRider, copy the google service account to '/' path. The service accounts location should be inside `~/.google`.
```bash
cd /
sudo cp -r ~/.google .
```

Seventh, start prefect server for the first time
```bash
conda activate capital_bike && prefect server start
```

Configure the PREFECT_API_URL
```bash
prefect config set PREFECT_API_URL=http://127.0.0.1:4200/api
```

Then, kill prefect server and shutdown your VM and start again.

Eighth, run the end-to-end pipeline automatically using automate_pipeline.sh script.
```bash
source setup/automate_pipeline.sh; tmux a -t capital_bike
```

If crashed happen like this on the Prefect,
```
crashed: Flow run infrastructure exited with non-zero status code 1.
```
Shutdown your VM, start again then re-run the above command.

Lastly, Go to `prefect/capital_bike_share/fact_bike_tripdata.sql` to uncomment `AND trip_route IS NOT NULL` to demonstrate data changes while using PipeRider.

Then, run the below command to compare each report.
```bash
conda activate capital_bike; source setup/run_piperider.sh data_modelling compare-reports
```

Wait until all runnings are finished, then inspect index.html, re-transform the table if needed and create a dashboard on Metabase. If using VSCode, download `ritwickdey.LiveServer` to see index.html file in the browser.

To kill tmux session.
```bash
tmux kill-session -t capital_bike
```

## Further Improvement
* Use python venv instead conda to create a virtual environment.
* Add Makefile.
* Add CI/CD test.
* Create a dashboard metrics in PipeRider.