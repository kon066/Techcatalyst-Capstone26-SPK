select distinct
    rate_code_id,

    case
        when rate_code_id = 1 then 'Standard rate'
        when rate_code_id = 2 then 'JFK'
        when rate_code_id = 3 then 'Newark'
        when rate_code_id = 4 then 'Nassau or Westchester'
        when rate_code_id = 5 then 'Negotiated fare'
        when rate_code_id = 6 then 'Group ride'
        else 'Other'
    end as rate_code_desc

from {{ ref('stg_taxi_trips') }}
where rate_code_id is not null