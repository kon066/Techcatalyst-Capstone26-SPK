with zones as (

    select *
    from {{ ref('stg_taxi_zone_lkp') }}

),

geo as (

    select *
    from {{ ref('stg_taxi_zones_geo') }}

)

select
    z.location_id,
    z.borough,
    z.zone,
    z.service_zone,

    g.objectid,
    g.shape_leng,
    g.shape_area,
    g.geometry_wkt

from zones z
left join geo g
    on z.location_id = g.locationid
