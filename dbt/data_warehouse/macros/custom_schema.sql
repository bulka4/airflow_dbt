"""
This macro is making sure that tables will be saved in the schema specified in the dbt_project.yml file. Otherwise dbt will use as a schema name a 
name obtained by contatenating schema names from profiles.yml and dbt_project.yml.
"""

{% macro generate_schema_name(custom_schema_name, node) %}
    {% if custom_schema_name is none %}
        {{ return(target.schema) }}
    {% else %}
        {{ return(custom_schema_name) }}
    {% endif %}
{% endmacro %}