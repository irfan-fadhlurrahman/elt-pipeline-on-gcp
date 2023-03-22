import os
import vaex
import datetime

from prefect import task, flow, tags
from prefect_gcp.cloud_storage import GcsBucket
from prefect_gcp.bigquery import BigQueryWarehouse
from prefect_dbt.cli.commands import DbtCoreOperation

from utils.parquet_to_gcs import read_dataframe, write_dataframe, get_month_range

from dotenv import load_dotenv
load_dotenv()

CREDENTIALS_BLOCK = os.environ.get("CREDENTIALS_BLOCK")
BUCKET_BLOCK = os.environ.get("BUCKET_BLOCK")
BQ_BLOCK = os.environ.get("BQ_BLOCK")
BUCKET_NAME = os.environ.get("BUCKET_NAME")
DATASET_NAME = os.environ.get("DATASET_NAME")
    
@flow()
def local_to_gcs_parent_flow(start_date: str, end_date: str):
    year_month_list = get_month_range(start_date, end_date)
    print(year_month_list)
    for year, month in year_month_list:
        date = datetime.datetime(int(year), int(month), 1)
        local_to_gcs_flow = local_to_gcs(date)
    
    external_table = create_external_bq_table(
        table_name="external_bike_table", 
        label="bike_trips",
        wait_for=[local_to_gcs_flow]
    )
    trigger_dbt_flow(
        project_dir="./capital_bike_share", 
        profiles_dir="./capital_bike_share",
        wait_for=[external_table]
    )
    
@task(log_prints=True)
def fetch_dataset(url_prefix: str, filename: str, label: str):
    print(f"Download zip file from {url_prefix}/{filename}.zip")
    os.system(f"wget {url_prefix}/{filename}.zip && mv *.zip data/{label}")
    
    print(f"Unzipping downloaded file")
    local_path = f"data/{label}/{filename}"
    os.system(f"unzip -od data/{label} {local_path}.zip")
    
    print(f"Read a CSV file from {local_path}.csv")
    try:
        return read_dataframe(f"{local_path}.csv", label)
    except FileNotFoundError:
        try:
            return read_dataframe(f"{local_path}.csv".replace("-", "_"), label)
        except FileNotFoundError:
            return read_dataframe(f"{local_path}.csv".replace("capital", "captial"), label)

@task(log_prints=True)
def write_to_parquet(df: vaex.dataframe.DataFrame, local_parquet_path: str):
    print('Convert CSV to Parquet')
    write_dataframe(df, local_parquet_path)
    
@task(log_prints=True)
def upload_to_gcs(local_parquet_path: str, gcs_parquet_path: str):
    print('Upload parquet file to GCS')
    gcs_block = GcsBucket.load(BUCKET_BLOCK)
    gcs_block.upload_from_path(
        from_path=local_parquet_path,
        to_path=gcs_parquet_path
    )

@task(log_prints=True)
def remove(label: str):
    print(f"Remove all zip and csv files")
    os.system(f"cd data/{label} && rm -rf *.zip *.csv *.parquet __MACOSX")
 
@flow()
def local_to_gcs(date: datetime.datetime):
    label = "bike_trips"
    filename = f"{date.year}{date.month:02}-capitalbikeshare-tripdata"
    url_prefix = f"https://s3.amazonaws.com/capitalbikeshare-data"
    local_parquet_path = f"data/{label}/{filename}.parquet"
    gcs_parquet_path = f"raw/{label}/{date.year}/{filename}.parquet"
    
    if not os.path.exists(f"data/{label}"):
        os.system(f"mkdir -p data/{label}")
    
    with tags(label):
        df = fetch_dataset(url_prefix, filename, label)
        csv_to_parquet = write_to_parquet(df, local_parquet_path, wait_for=[df])
        parquet_to_data_lake = upload_to_gcs(local_parquet_path, gcs_parquet_path, wait_for=[csv_to_parquet])
        remove(label, wait_for=[parquet_to_data_lake])
    
@flow()
def create_external_bq_table(table_name: str, label: str):
    with BigQueryWarehouse.load(BQ_BLOCK) as warehouse:
        operation = f"""
            CREATE OR REPLACE EXTERNAL TABLE `{DATASET_NAME}.{table_name}`
            OPTIONS (
                format = 'PARQUET',
                uris = ['gs://{BUCKET_NAME}/raw/{label}/20*']
            );
        """
        warehouse.execute(operation)

@flow()
def trigger_dbt_flow(project_dir: str, profiles_dir: str):
    result = DbtCoreOperation(
        commands=["pwd", "dbt debug", "dbt deps", "dbt run"],
        project_dir=project_dir,
        profiles_dir=profiles_dir
    ).run()
    return result
    
if __name__ == "__main__":
    start_date = "2023/01/01"
    end_date = "2023/01/31"
    
    local_to_gcs_parent_flow(start_date, end_date)