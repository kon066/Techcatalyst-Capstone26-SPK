select distinct
    cast(pickup_datetime as date) as pickup_date,

    extract(day from pickup_datetime) as pickup_day,
    dayofweek(pickup_datetime) as pickup_day_of_week,
    extract(month from pickup_datetime) as pickup_month,
    extract(quarter from pickup_datetime) as pickup_quarter,
    extract(year from pickup_datetime) as pickup_year,
    weekofyear(pickup_datetime) as pickup_week_of_year,
    monthname(pickup_datetime) as pickup_month_name,
    dayname(pickup_datetime) as pickup_day_name,

    case
        when dayofweek(pickup_datetime) in (1, 7) then true
        else false
    end as is_weekend

from {{ ref('fact_taxi_trip') }}
where pickup_datetime is not null