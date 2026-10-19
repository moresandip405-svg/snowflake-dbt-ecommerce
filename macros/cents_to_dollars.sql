{% macro cents_to_dollars(column_name, scale=2) -%}
    round(cast({{ column_name }} as numeric(18, 4)), {{ scale }})
{%- endmacro %}
