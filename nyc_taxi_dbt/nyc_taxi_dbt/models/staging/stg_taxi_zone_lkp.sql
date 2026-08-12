select
    locationid as location_id,
    borough,
    zone,
    service_zone
from {{ source('silver', 'taxi_zone_lkp') }}