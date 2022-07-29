/*
With inspiration from https://discourse.getdbt.com/t/faq-cleaning-up-removed-models-from-your-production-schema/113
This macro compares each in-use database's information schema with the current graph's nodes to
identify tables which no longer have a corresponding dbt model. It then runs a drop statement
for each occurrence.

To test, use the dry_run argument to log the drop statements without actually running them:
dbt run-operation drop_old_tables --args "{dry_run: 'true'}"
*/

{% macro drop_old_tables(dry_run='false') %}
    {% if execute %}
        {% set current_model_locations={} %}
        {% for node in graph.nodes.values() | selectattr("resource_type", "in", ["model", "seed", "snapshot"])%}
            {% if not node.database in current_model_locations %}
                {% do current_model_locations.update({node.database: {}}) %}
            {% endif %}
            {% if not node.schema.upper() in current_model_locations[node.database] %}
                {% do current_model_locations[node.database].update({node.schema.upper(): []}) %}
            {% endif %}
            {% set table_name = node.alias if node.alias else node.name %}
            {% do current_model_locations[node.database][node.schema.upper()].append(table_name.upper()) %}
        {% endfor %}
    {% endif %}
    {% set cleanup_query %}

        with models_to_drop as (
            {% for database in current_model_locations.keys() %}
            {% if loop.index > 1 %}
            union all
            {% endif %}
            select
                table_type
                , table_catalog
                , table_schema
                , table_name
                , case
                    when table_type = 'BASE TABLE' then 'TABLE'
                    when table_type = 'VIEW' then 'VIEW'
                end as relation_type
                , concat_ws('.', table_catalog, table_schema, table_name) as relation_name
            from {{ database }}.information_schema.tables
            where table_schema in ('{{ "', '".join(current_model_locations[database].keys()) }}')
            and not (
                {% for schema in current_model_locations[database].keys() %}
                {% if loop.index > 1 %}or {% endif %}table_schema = '{{ schema }}' and table_name in ('{{ "', '".join(current_model_locations[database][schema]) }}')
                {% endfor %}
            )
            {% endfor %}
        )

        select 'drop ' || relation_type || ' ' || relation_name || ';' as drop_commands
        from models_to_drop
        -- intentionally exclude unhandled table_types, including 'external table`
        where drop_commands is not null

    {% endset %}
    {% do log(cleanup_query, info=True) %}
    {% set drop_commands = run_query(cleanup_query).columns[0].values() %}
    {% if drop_commands %}
        {% for drop_command in drop_commands %}
            {% do log(drop_command, True) %}
            {% if dry_run == 'false' %}
                {% do run_query(drop_command) %}
            {% endif %}
        {% endfor %}
    {% else %}
        {% do log('No relations to clean.', True) %}
    {% endif %}
{%- endmacro -%}
