/* This is a simple intermediate model that brings the latest product's information date.
Its purpose is to demonstrate the usage of intermedate models. */

with int_product_max_date as (
    
    select 
        product_details.product_id, 
        max(product_details.snapshot_at_et) as max_snapshot_at_et
    from {{ ref('snowflake__product_details') }} product_details 
    group by product_details.product_id

)

select
    product_id
    , max_snapshot_at_et
from int_product_max_date