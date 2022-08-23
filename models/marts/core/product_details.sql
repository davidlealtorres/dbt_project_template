with int_product_max_date as (
    select * from {{ ref('int_product_max_date') }}
)

, product_details as (
  
 select
    product_details.product_id
    , product_details.product_brand
    , product_details.product_name
    , product_details.product_price_usd
    , product_details.product_shipping_weight_lb
    , product_details.flag_is_product_prime 
    , product_details.product_dimension_x_in
    , product_details.product_dimension_y_in
    , product_details.product_dimension_z_in
    , product_details.product_volume_in3
    , product_details.product_weight_lb
    , product_details.product_stars_rating
    , product_details.product_superclient_rating
  from  {{ ref('snowflake__product_details') }} product_details 
  /* Join to intermediate model int_product_max_date to bring the latest product's information */ 
  inner join int_product_max_date on product_details.snapshot_at_et = int_product_max_date.max_snapshot_at_et 
    and product_details.product_id = int_product_max_date.product_id
  
)

select
   
   /* Primary Key */
   product_id

   /* Properties and Statuses */
    , product_brand
    , product_name
    , product_price_usd
    , product_shipping_weight_lb
    , flag_is_product_prime 
    , product_dimension_x_in
    , product_dimension_y_in
    , product_dimension_z_in
    , product_volume_in3
    , product_weight_lb
    , product_stars_rating
    , product_superclient_rating

from product_details
