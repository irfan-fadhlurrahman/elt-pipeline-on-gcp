{{ config(materialized="view") }}

WITH hourly_trips AS (
    SELECT
        ride_id,
        member_casual,
        duration_in_seconds,
        EXTRACT(HOUR FROM started_at) AS hour_of_day,
    FROM
        {{ ref('fact_bike_tripdata') }}
)
-- Which hour of the day has the most active members to use the bike?
SELECT
    hour_of_day,
    member_casual,
    COUNT(ride_id) AS total_trips_per_day,
    AVG(duration_in_seconds / 60) AS avg_duration_in_minutes
FROM
    hourly_trips
GROUP BY
    hour_of_day, member_casual
ORDER BY
    hour_of_day, member_casual