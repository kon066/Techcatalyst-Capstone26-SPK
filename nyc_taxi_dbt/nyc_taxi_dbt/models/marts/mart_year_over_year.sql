{{ config(materialized='view') }}

select
    d.pickup_date,
    d.pickup_year,
    d.pickup_month,
    d.pickup_month_name,

    l.zone as pickup_zone,

    count(*) as trip_count,

    sum(f.total_amount) as total_revenue,

    round(
        sum(f.total_amount) / nullif(count(*), 0),
        2
    ) as revenue_per_trip

from {{ ref('fact_taxi_trip') }} f
join {{ ref('dim_date') }} d
    on f.pickup_date = d.pickup_date
join {{ ref('dim_location') }} l
    on f.pu_location_id = l.location_id

group by
    1,2,3,4,5