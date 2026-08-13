{{ config(materialized='view') }}

with trips as (

    select *
    from {{ ref('fact_taxi_trip') }}

),

pickup_locations as (

    select
        location_id,
        zone,
        borough,
        service_zone,
        objectid,
        shape_leng,
        shape_area,
        geometry_wkt
    from {{ ref('dim_location') }}

),

final as (

    select
        p.location_id as pickup_location_id,
        p.zone as pickup_zone,
        p.borough as pickup_borough,
        p.service_zone as pickup_service_zone,

        p.objectid,
        p.shape_leng,
        p.shape_area,
        p.geometry_wkt,

        count(*) as trip_count,
        sum(t.total_amount) - sum(t.tip_amount) as total_revenue_before_tip,
        avg(t.total_amount) as avg_revenue_per_trip,
        avg(t.fare_amount) as avg_fare,

        avg(
            case
                when t.is_credit_card_trip = 1
                then t.tip_amount
            end
        ) as avg_tip_credit_card_only,

        avg(t.trip_distance) as avg_trip_distance

    from trips t
    left join pickup_locations p
        on t.pu_location_id = p.location_id

    group by
        p.location_id,
        p.zone,
        p.borough,
        p.service_zone,
        p.objectid,
        p.shape_leng,
        p.shape_area,
        p.geometry_wkt

)

select *
from final