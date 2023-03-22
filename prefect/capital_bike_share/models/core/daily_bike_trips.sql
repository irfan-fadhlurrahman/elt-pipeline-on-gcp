{{ config(materialized="view") }}

WITH daily_trips AS (
    SELECT
        ride_id,
        duration_in_seconds,
        EXTRACT(DAYOFWEEK FROM started_at) AS day_of_week,
    FROM
        {{ ref('fact_bike_tripdata') }}
)
-- What are the number of rides and average durations by day of week?
SELECT
    day_of_week,
    {{ get_day_name('day_of_week') }} AS day_name,
    COUNT(ride_id) AS total_rides,
    AVG(duration_in_seconds / 60) AS avg_duration_in_minutes
FROM
    daily_trips
GROUP BY
    day_of_week, day_name
ORDER BY
    day_of_week, day_name
