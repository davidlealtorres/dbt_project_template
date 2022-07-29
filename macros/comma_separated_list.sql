{% macro comma_separated_list(list) %}

{% for l in list %}

{{l}} {% if not loop.last %},{% endif %}

{% endfor %}

{% endmacro %}
