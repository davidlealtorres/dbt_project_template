{#
Override the built-in `generate_database_name` macro so custom databases are ignored for non-deployment targets,
where custom database names are instead incorporated into the schema name.

https://docs.getdbt.com/docs/building-a-dbt-project/building-models/using-custom-databases/
#}
{% macro generate_database_name(custom_database_name, node) %}

    {% set default_database = target.database %}

    {% if is_deployment() and custom_database_name is not none %}
        {{ return(custom_database_name | trim) }}
    {% else %}
        {{ return(default_database) }}
    {% endif %}

{% endmacro %}
