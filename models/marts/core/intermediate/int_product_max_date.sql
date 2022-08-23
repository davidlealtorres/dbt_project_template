with int_product_max_date as (
    
    select 
        asin, 
        max(snapshot_ts) as max_date
    from "DATAHAWK_SHARE_DEMO_SNOWFLAKE_SECURE_SHARE_1629840906256"."PRODUCT"."PRODUCT_DETAILED" pd
    group by asin

)

select
    asin
    , max_date
from int_product_max_date