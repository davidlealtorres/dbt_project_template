with int_product_max_date as (
    select * from {{ ref('int_product_max_date') }}
)

, product_details as (
  
 select
  pd.asin
  , pd.brand
  , pd.name
  , pd.price as price_usd
  , pd.shipping_weight as shipping_weight_lb
  , pd.is_prime 
  , pd.dimension_x as dimension_x_in
  , pd.dimension_y as dimension_y_in
  , pd.dimension_z as dimension_z_in
  , {{ calculate_volume('pd.dimension_x', 'pd.dimension_y', 'pd.dimension_z', 2) }} as volume_in3
  , pd.weight as product_weight_lb
  , pd.review_rating as stars_rating
  , {{ superclient_rating('pd.review_rating') }} as superclient_rating
  from  "DATAHAWK_SHARE_DEMO_SNOWFLAKE_SECURE_SHARE_1629840906256"."PRODUCT"."PRODUCT_DETAILED" pd 
  inner join int_product_max_date pdmd on pd.snapshot_ts = pdmd.max_date and pd.asin = pdmd.asin
  
)

select
    asin
    , brand
    , name
    , price_usd
    , shipping_weight_lb
    , is_prime 
    , dimension_x_in
    , dimension_y_in
    , dimension_z_in
    , volume_in3
    , product_weight_lb
    , stars_rating
    , superclient_rating
from product_details
