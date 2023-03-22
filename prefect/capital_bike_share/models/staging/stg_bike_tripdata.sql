{{ config(materialized='view') }}

WITH bike_trips AS (
    SELECT
        ride_id,
        rideable_type,
        started_at,
        ended_at,
        NULLIF(start_station_name, '') AS start_station_name,
        NULLIF(start_station_id, '') AS start_station_id,
        NULLIF(end_station_name, '') AS end_station_name,
        NULLIF(end_station_id, '') AS end_station_id,
        start_lat,
        start_lng,
        end_lat,
        end_lng,
        member_casual,
        ROW_NUMBER() OVER(PARTITION BY ride_id, started_at) AS row_number
    FROM
        {{ source('staging', 'external_bike_table') }}
    WHERE
        ride_id IS NOT NULL
)
SELECT
    ride_id,
    rideable_type,
    started_at,
    ended_at,
    start_station_name,
    CAST(start_station_id AS INTEGER) AS start_station_id,
    end_station_name,
    CAST(end_station_id AS INTEGER) AS end_station_id,
    start_lat AS start_latitude,
    start_lng AS start_longitude,
    end_lat AS end_latitude,
    end_lng AS end_longitude,
    member_casual
FROM
    bike_trips
WHERE
    (start_station_id != 'MTL-ECO5-03' OR end_station_id != 'MTL-ECO5-03')
    AND row_number = 1