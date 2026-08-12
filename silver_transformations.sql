-- deleted 7 rows that had pickup times before and after our data timeline.
DELETE FROM taxi_trips_standardized WHERE YEAR(pickup_datetime) < 2024 OR YEAR(pickup_datetime) > 2026;

-- deleted 3621 rows, total amount less than initial fare
DELETE FROM taxi_trips_standardized WHERE total_amount < 3.00 AND trip_distance > 0;

-- deleted 1670 rows, filters out insanely high trip distance, outliers
SELECT COUNT(*) FROM (SELECT * FROM YELLOW_TAXI_RAW UNION SELECT * FROM GREEN_TAXI_RAW) WHERE trip_distance > 200;
 
-- deleted 13,338,842 rows, total amount does not equal all charges total.
SELECT COUNT(*) FROM (SELECT * FROM YELLOW_TAXI_RAW UNION SELECT * FROM GREEN_TAXI_RAW) WHERE ABS(
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
        ) > 1.00;

-- deleted 9,248,993 rows, drops if passenger count is 0 or null
SELECT COUNT(*) FROM (SELECT * FROM YELLOW_TAXI_RAW UNION SELECT * FROM GREEN_TAXI_RAW) WHERE passenger_count IS NULL OR passenger_count = 0;