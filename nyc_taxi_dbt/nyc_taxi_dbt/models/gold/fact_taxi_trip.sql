select
    md5(
        concat_ws(
            '|',
            vendor_id,
            pickup_datetime,
            dropoff_datetime,
            pu_location_id,
            do_location_id,
            total_amount
        )
    ) as trip_key,

    vendor_id,
    cast(pickup_datetime as date) as pickup_date,
    pu_location_id,
    do_location_id,
    payment_type,
    rate_code_id,
    taxi_type,

    pickup_datetime,
    dropoff_datetime,
    passenger_count,
    trip_distance,
    store_and_fwd_flag,

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

    timestampdiff(
        minute,
        pickup_datetime,
        dropoff_datetime
    ) as trip_duration_minutes,

    extract(hour from pickup_datetime) as pickup_hour,

    case
        when payment_type = 1
         and fare_amount > 0
        then tip_amount / fare_amount
    end as tip_pct,

    case when payment_type = 1 then 1 else 0 end as is_credit_card_trip,

    case when payment_type = 2 then 1 else 0 end as is_cash_trip,

    case
        when trip_distance > 0
        then total_amount / trip_distance
    end as revenue_per_mile

from {{ ref('stg_taxi_trips') }}