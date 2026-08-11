USE ROLE DE;
USE WAREHOUSE COMPUTE_WH;
USE DATABASE TECHCATALYST;
USE SCHEMA TECHCATALYST.GROUP_SPK;

SELECT *
FROM yellow_taxi_standardized
WHERE
    fare_amount >= 0
    AND total_amount >= 0
    AND passenger_count IS NOT NULL
    AND passenger_count > 0
    AND trip_distance > 0
    AND trip_distance <= 200
    AND dropoff_datetime > pickup_datetime
    AND DATEDIFF(
            minute,
            pickup_datetime,
            dropoff_datetime
        ) BETWEEN 1 AND 240
    AND NOT (
        trip_distance = 0
        AND fare_amount > 10
    )
    AND ABS(
            total_amount -
            (
                COALESCE(fare_amount, 0) +
                COALESCE(extra, 0) +
                COALESCE(mta_tax, 0) +
                COALESCE(improvement_surcharge, 0) +
                COALESCE(congestion_surcharge, 0) +
                COALESCE(airport_fee, 0) +
                COALESCE(tip_amount, 0) +
                COALESCE(tolls_amount, 0)
            )
        ) <= 1.00;
