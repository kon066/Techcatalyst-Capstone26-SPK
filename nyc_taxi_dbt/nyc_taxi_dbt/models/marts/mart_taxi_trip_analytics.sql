{{ config(materialized='view') }}
select
    f.trip_key,

    -- Original/base trip fields
    f.vendor_id,
    f.pickup_datetime,
    f.dropoff_datetime,
    f.passenger_count,
    f.trip_distance,
    f.rate_code_id,
    f.store_and_fwd_flag,
    f.pu_location_id,
    f.do_location_id,
    f.payment_type,
    f.fare_amount,
    f.extra,
    f.mta_tax,
    f.tip_amount,
    f.tolls_amount,
    f.improvement_surcharge,
    f.total_amount,
    f.congestion_surcharge,
    f.airport_fee,
    f.cbd_congestion_fee,
    f.taxi_type,

    -- Derived time metrics
    f.trip_duration_minutes,
    f.pickup_hour,

    d.pickup_day,
    d.pickup_day_of_week,
    d.pickup_month,
    d.pickup_quarter,
    d.pickup_year,
    d.pickup_week_of_year,
    d.pickup_date,
    d.pickup_month_name,
    d.pickup_day_name,
    d.is_weekend,

    -- Tip/payment metrics
    f.tip_pct,
    f.is_credit_card_trip,
    f.is_cash_trip,

    -- Revenue metrics
    f.revenue_per_mile,

    -- Payment
    p.payment_type_desc,

    -- Rate Code
    r.rate_code_desc,



    -- Geographic analytics
    case
        when pu.borough = do_loc.borough then 1
        else 0
    end as is_same_borough,

    case
        when pu.borough <> do_loc.borough then 1
        else 0
    end as interborough_trip,

    case
        when pu.zone in (
            'JFK Airport',
            'LaGuardia Airport',
            'Newark Airport'
        )
        then 1
        else 0
    end as is_airport_pickup,

    case
        when do_loc.zone in (
            'JFK Airport',
            'LaGuardia Airport',
            'Newark Airport'
        )
        then 1
        else 0
    end as is_airport_dropoff,

    -- Pickup geography
    pu.zone as pu_name,
    pu.borough as pu_borough,
    pu.service_zone as pu_service_zone,

    -- Dropoff geography
    do_loc.zone as do_name,
    do_loc.borough as do_borough,
    do_loc.service_zone as do_service_zone,

    -- Optional route fields for Tableau maps
    concat(pu.borough, ' -> ', do_loc.borough) as borough_route,
    concat(pu.zone, ' -> ', do_loc.zone) as zone_route

from {{ ref('fact_taxi_trip') }} f

left join {{ ref('dim_date') }} d
    on f.pickup_date = d.pickup_date

left join {{ ref('dim_location') }} pu
    on f.pu_location_id = pu.location_id

left join {{ ref('dim_location') }} do_loc
    on f.do_location_id = do_loc.location_id

left join {{ ref('dim_payment_type') }} p
    on f.payment_type = p.payment_type

left join {{ ref('dim_rate_code') }} r
    on f.rate_code_id = r.rate_code_id

