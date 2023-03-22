{{ config(
    materialized='table',
    partition_by={
        "field": "started_at",
        "data_type": "timestamp",
        "granularity": "day"
    },
    cluster_by = "rideable_type"
) 
}}
WITH fact_bikes AS (
    SELECT
        *,
        TIMESTAMP_DIFF(ended_at, started_at, SECOND) AS duration_in_seconds,
        CONCAT(start_station_name, ' - ', end_station_name) AS trip_route
    FROM
        {{ ref('stg_bike_tripdata') }}
)
SELECT
    *
FROM
    fact_bikes
WHERE
    duration_in_seconds > 0
    -- AND trip_route IS NOT NULL

