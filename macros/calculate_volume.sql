/* This macro calculates the volume based on 3 dimensions */

{% macro calculate_volume(width, depth, height, decimal_places=3) -%}
    round({{ width }} * {{ depth }} * {{ height }}, {{ decimal_places }})
{%- endmacro %}