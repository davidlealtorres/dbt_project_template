select
    product_details.asin as product_id
    , product_details.brand as product_brand
    , product_details.name as product_name
    , product_details.price as product_price_usd
    , product_details.shipping_weight as product_shipping_weight_lb
    , product_details.is_prime as flag_is_product_prime 
    , product_details.dimension_x as product_dimension_x_in
    , product_details.dimension_y as product_dimension_y_in
    , product_details.dimension_z as product_dimension_z_in
    , {{ calculate_volume('product_details.dimension_x', 'product_details.dimension_y', 'product_details.dimension_z', 2) }} as product_volume_in3
    , product_details.weight as product_weight_lb
    , product_details.review_rating as product_stars_rating
    , {{ superclient_rating('product_details.review_rating') }} as product_superclient_rating
    , snapshot_ts as snapshot_at_et
  from  "DATAHAWK_SHARE_DEMO_SNOWFLAKE_SECURE_SHARE_1629840906256"."PRODUCT"."PRODUCT_DETAILED" product_details 