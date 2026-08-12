SELECT *
FROM green_taxi_bronze
WHERE
    fare_amount >= 0
    AND fare_amount >= 3
    AND total_amount >= 0
    AND passenger_count IS NOT NULL
    AND passenger_count > 0
    AND trip_distance > 0
    AND trip_distance <= 200
    AND lpep_dropoff_datetime > lpep_pickup_datetime
    AND pulocationid <= 263 
    AND dolocationid <= 263
    AND YEAR(lpep_pickup_datetime) BETWEEN 2024 AND 2026
    AND YEAR(lpep_dropoff_datetime) BETWEEN 2024 AND 2026
    AND DATEDIFF(
            minute,
            lpep_pickup_datetime,
            lpep_dropoff_datetime
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
                COALESCE(tip_amount, 0) +
                COALESCE(tolls_amount, 0)
            )
        ) <= 1.00;
