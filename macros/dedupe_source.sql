/*
This macro can be used to deduplicate source data. Example usage:

    select *
    from {{ dedupe_source(source('stripe', 'payments'), ['id'], '_sdc_sequence') }}

*/

{% macro dedupe_source(tablename, partition_fields, order_by_field) %}

(select *
from (

    select
        *,
        row_number() over (partition by {{ comma_separated_list(partition_fields) }} order by {{ order_by_field }} desc) = 1 as is_latest_record
    from {{ tablename }}

)
where is_latest_record = True)

{% endmacro %}
