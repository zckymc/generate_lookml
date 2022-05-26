{% macro generate_lookml(model_name) %}

{% set lookml_output = [] %}

{% set model = (graph.nodes.values() | selectattr('name', 'equalto', model_name) | list).pop() %}

{% set info_query %}
    select

        table_schema,
        table_name,
        column_name,
        data_type,
        comment

    from {{ model.database }}.information_schema.columns
    where table_name = upper('{{ model.name}}')
    order by ordinal_position
{% endset %}

{% set lookml_header %}
view: {{ model.name }} {
  sql_table_name: "{{ model.database | upper }}"."{{ model.schema | upper }}"."{{ model.name | upper }}";;
{% endset %}

{% do lookml_output.append(lookml_header) %}
{% do lookml_output.append('') %}

{%- set snowflake_to_looker_datatypes =
    {
        'ARRAY': 'string',
        'BIGINT': 'number',
        'BINARY': 'string',
        'BOOLEAN': 'yesno',
        'CHAR': 'string',
        'CHARACTER': 'string',
        'DATE': 'date',
        'DATETIME': 'datetime',
        'DECIMAL': 'number',
        'DOUBLE PRECISION': 'number',
        'DOUBLE': 'number',
        'FLOAT': 'number',
        'FLOAT4': 'number',
        'FLOAT8': 'number',
        'GEOGRAPHY': 'string',
        'INT': 'number',
        'INTEGER': 'number',
        'NUMBER': 'number',
        'NUMERIC': 'number',
        'OBJECT': 'string',
        'REAL': 'number',
        'SMALLINT': 'number',
        'STRING': 'string',
        'TEXT': 'string',
        'TIME': 'string',
        'TIMESTAMP': 'timestamp',
        'TIMESTAMP_NTZ': 'timestamp',
        'VARBINARY': 'string',
        'VARCHAR': 'string',
        'VARIANT': 'string',
    }
-%}

{% set info_query_result = run_query(info_query) %}

{%- for row in info_query_result.rows -%}

    {% set output %}
  dimension: {{ row.COLUMN_NAME | lower }} {
    type: {{ snowflake_to_looker_datatypes[row.DATA_TYPE] }}
    sql: ${TABLE}."{{ row.COLUMN_NAME }}";;
    description: "{{ row.COMMENT }}"
    hidden: {{ "yes" if row.COLUMN_NAME.startswith('_') else "no" }}
  }
    {% endset %}

    {% do lookml_output.append(output) %}
    {% do lookml_output.append('}') if loop.last  %}

{%- endfor -%}

    {% set lookml_output = lookml_output | join ('') %}
    {{ log(lookml_output, info=True) }}
    {% do return(lookml_output) %}

{%- endmacro -%}
