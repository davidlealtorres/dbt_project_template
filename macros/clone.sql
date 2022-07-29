/* clone_schemas_to_target
Used for creating a clone of the specified database schemas in the current target.
Used for local development and for creating a full copy of latest tables when using slim
CI and a tool like Spectacles which requires all model tables be present.
Example usage:
dbt run-operation clone_schemas_to_target --args "{source_database: 'analytics', schemas: ['core', 'sources', 'utils']}"
Optionally drop any tables which no longer exist in the project, requires role to have ownership of the tables:
dbt run-operation clone_schemas_to_target --args "{source_database: 'analytics', schemas: ['core', 'sources', 'utils'], should_drop_old_tables: True}"
*/

{% macro clone_schemas_to_target(database, should_drop_old_tables=False) %}
    {% set show_schemas_query %}
    select schema_name from {{ database }}.information_schema.schemata;
    {% endset %}
    {% set cloneable_chemas = run_query(show_schemas_query).columns[0].values() %}

    {% for schema in cloneable_chemas %}
        {% if schema != "INFORMATION_SCHEMA" %}
            {% set clone_command -%}
                create or replace schema {{ target.database }}.{{ target.schema }}_{{ schema }} clone {{ database }}.{{ schema }}
            {%- endset %}
            {% do log('Running ' ~ clone_command, info=True) %}
            {% do run_query(clone_command) %}
        {% endif %}
    {% endfor %}

    {% if should_drop_old_tables %}
        {% do drop_old_tables() %}
    {% endif %}
    {% do log('Done!', info=True) %}

{% endmacro %}

/* clone_from_analytics_staging_with_drop
Useful for PR test jobs in dbt Cloud when Spectacles is used.
This should be run before any dbt run/build commands.
*/
{% macro clone_from_analytics_with_drop() %}
{% do clone_schemas_to_target('analytics', should_drop_old_tables=True) %}
{% endmacro %}

/* clone_from_analytics_without_drop
Useful for local development to copy of the latest tables in production into dev schemas.
*/
{% macro clone_from_analytics_without_drop() %}
{% do clone_schemas_to_target('analytics') %}
{% endmacro %}

/* Alias for clone_from_analytics_without_drop */
{% macro dev_clone() %}
{% do clone_from_analytics_without_drop() %}
{% endmacro %}
