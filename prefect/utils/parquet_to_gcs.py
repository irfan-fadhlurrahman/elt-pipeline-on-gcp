import os
import logging

import vaex
import pyarrow as pa

from pyarrow import csv
from prefect_gcp.cloud_storage import GcsBucket
from IPython.display import display
from datetime import datetime, timedelta

class VaexDataFrame:
    
    def __init__(self, read_options=None, convert_options=None):
        self.read_options = read_options
        self.convert_options = convert_options
    
    def read(self, dataset_path):
        if dataset_path.endswith((".csv", ".csv.gz")):
            return vaex.from_csv_arrow(
                dataset_path, 
                read_options=self.read_options,
                convert_options=self.convert_options
            )
        elif dataset_path.endswith(".parquet"):
            return vaex.open(dataset_path)
        else:
            logging.error("Currently only accept csv and parquet file")
            return None
        
    def write(self, df, output_path):
        if not output_path.endswith('.parquet'):
            logging.error("Currently only convert to parquet")
            return None
        df.export_parquet(output_path)
  
def write_dataframe(df, output_path):
    VaexDataFrame().write(df, output_path)
    
def read_dataframe(path, label="bike_trips"):
    if label == "bike_trips":
        column_dtypes = {
            "ride_id": pa.string(),
            "rideable_type": pa.string(),
            "started_at": pa.timestamp('s'),
            "ended_at": pa.timestamp('s'),
            "start_station_name": pa.string(),
            "start_station_id": pa.string(),
            "end_station_name": pa.string(),
            "end_station_id": pa.string(),
            "start_lat": pa.float64(),
            "start_lng": pa.float64(),
            "end_lat": pa.float64(),
            "end_lng": pa.float64(),
            "member_casual": pa.string()
        }
        read_options = csv.ReadOptions(
            column_names=list(column_dtypes.keys()),
            skip_rows=1,
        )
        convert_options = csv.ConvertOptions(
            column_types=column_dtypes,
            null_values=['-', ''],
        )
        vaex_df = VaexDataFrame(
            read_options=read_options,
            convert_options=convert_options
        )
        return vaex_df.read(path)
    
    elif label == "hourly_weather":
        return VaexDataFrame().read(path)
    else:
        return VaexDataFrame().read(path)

def get_month_range(start_date: str, end_date: str):
    _start_date = datetime.strptime(start_date, "%Y/%m/%d")
    _end_date = datetime.strptime(end_date, "%Y/%m/%d")

    date_generated = [
        _start_date + timedelta(days=x) 
        for x in range(0, (_end_date - _start_date).days) 
        if x%29 == 0
    ]
    month_year = [
        (date.year, date.month) 
        for date in date_generated
    ]
    return sorted(set(month_year))
     
def upload_to_gcs(bucket_block, local_path, gcs_path):
    gcs_block = GcsBucket.load(bucket_block)
    gcs_block.upload_from_path(
        from_path=local_path,
        to_path=gcs_path
    )
    
def main():
    path = "/home/irfanfadh43/private/prefect/data/bike_trips/202212-capitalbikeshare-tripdata.parquet"  
      
    df = read_dataframe(path, label="bike_trips")
    print(df)
    # for col in df.get_column_names():
    #     print(col, ":", df[col].dtype)
    
    # path = "data/2021_hourly_weather.csv.gz"
    # df = read_dataframe(path, label="hourly_weather")
    # for col in df.get_column_names():
    #     print(col, ":", df[col].dtype)
    
    
if __name__ == "__main__":
    main()