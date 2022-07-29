{#
Returns whether the current run is a deployment where custom database/schema names should be used verbatim.
This can be overridden by specifying an `is_deployment` boolean variable.
#}
{% macro is_deployment() %}

    {{ return(var('is_deployment', target.name in var('deployment_target_names'))) }}

{% endmacro %}
