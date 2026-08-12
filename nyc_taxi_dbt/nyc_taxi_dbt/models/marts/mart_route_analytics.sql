{{ config(materialized='view') }}

with trips as (

    select *
    from {{ ref('fact_taxi_trip') }}

),

locations as (

    select
        location_id,
        zone,
        borough,
        service_zone
    from {{ ref('dim_location') }}

),

final as (

    select
        pu.location_id as pickup_location_id,
        pu.zone as pickup_zone,
        pu.borough as pickup_borough,
        pu.service_zone as pickup_service_zone,

        do_loc.location_id as dropoff_location_id,
        do_loc.zone as dropoff_zone,
        do_loc.borough as dropoff_borough,
        do_loc.service_zone as dropoff_service_zone,

        concat(pu.borough, ' -> ', do_loc.borough) as borough_route,
        concat(pu.zone, ' -> ', do_loc.zone) as zone_route,

        count(*) as trip_count,
        sum(t.total_amount) as total_revenue,
        avg(t.total_amount) as avg_revenue_per_trip,
        avg(t.fare_amount) as avg_fare,
        avg(
            case
                when is_credit_card_trip = 1
                then tip_amount
            end
        ) as avg_tip_credit_card_only,
        avg(t.trip_distance) as avg_trip_distance,
        avg(t.trip_duration_minutes) as avg_trip_duration_minutes

    from trips t

    left join locations pu
        on t.pu_location_id = pu.location_id

    left join locations do_loc
        on t.do_location_id = do_loc.location_id

    group by
        pu.location_id,
        pu.zone,
        pu.borough,
        pu.service_zone,
        do_loc.location_id,
        do_loc.zone,
        do_loc.borough,
        do_loc.service_zone

)

select *
from final