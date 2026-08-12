select
    objectid,
    shape_leng,
    shape_area,
    zone,
    locationid,
    borough,
    geometry_wkt
from {{ source('silver', 'taxi_zones_geo') }}