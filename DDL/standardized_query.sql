USE ROLE DE;
USE WAREHOUSE COMPUTE_WH;
USE DATABASE TECHCATALYST;
USE SCHEMA TECHCATALYST.GROUP_SPK;

CREATE OR REPLACE TABLE taxi_trips_standardized (
    taxi_type                STRING,          -- YELLOW or GREEN
    vendor_id                INT,
    pickup_datetime          TIMESTAMP,
    dropoff_datetime         TIMESTAMP,
    passenger_count          INT,
    trip_distance            DOUBLE,
    rate_code_id             INT,
    store_and_fwd_flag       STRING,
    pu_location_id           INT,
    do_location_id           INT,
    payment_type             INT,
    fare_amount              DOUBLE,
    extra                    DOUBLE,
    mta_tax                  DOUBLE,
    tip_amount               DOUBLE,
    tolls_amount             DOUBLE,
    improvement_surcharge    DOUBLE,
    total_amount             DOUBLE,
    congestion_surcharge     DOUBLE,
    airport_fee              DOUBLE,          -- Yellow only
    cbd_congestion_fee       DOUBLE,          -- 2025+
    trip_type                INT             -- Green only
);

CREATE OR REPLACE TABLE taxi_trips_standardized AS

SELECT
    'YELLOW' AS taxi_type,
    VendorID                    AS vendor_id,
    tpep_pickup_datetime        AS pickup_datetime,
    tpep_dropoff_datetime       AS dropoff_datetime,
    passenger_count,
    trip_distance,
    RatecodeID                  AS rate_code_id,
    store_and_fwd_flag,
    PULocationID                AS pu_location_id,
    DOLocationID                AS do_location_id,
    payment_type,
    fare_amount,
    extra,
    mta_tax,
    tip_amount,
    tolls_amount,
    improvement_surcharge,
    total_amount,
    congestion_surcharge,
    airport_fee,
    cbd_congestion_fee,
    NULL AS trip_type
FROM yellow_taxi_bronze

UNION ALL

SELECT
    'GREEN' AS taxi_type,
    VendorID                    AS vendor_id,
    lpep_pickup_datetime        AS pickup_datetime,
    lpep_dropoff_datetime       AS dropoff_datetime,
    passenger_count,
    trip_distance,
    RatecodeID                  AS rate_code_id,
    store_and_fwd_flag,
    PULocationID                AS pu_location_id,
    DOLocationID                AS do_location_id,
    payment_type,
    fare_amount,
    extra,
    mta_tax,
    tip_amount,
    tolls_amount,
    improvement_surcharge,
    total_amount,
    congestion_surcharge,
    NULL AS airport_fee,
    cbd_congestion_fee,
    trip_type
FROM green_taxi_bronze;