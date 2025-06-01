-- Get date of the first day of the financial year 5 years ago.

{% macro date_x_fy_ago(num_of_years) %}
    """
    This function is returning a date which is the beginning of a financial year num_of_year of years ago. 
    It assumes that a financial years starts at 1st Oct.
    """
    {% set num_of_years = num_of_years | int %}

    -- Read the below query only if dbt is in 'execute' mode (it executes SQL queries).
    {% if execute %}
        {% set query %}
            select
                case
                    when month(getdate()) < 10 then datefromparts(year(getdate()) - {{ num_of_years }}, 10, 1)
                    else datefromparts(year(getdate()) - {{ num_of_years - 1 }}, 10, 1)
                end 
                as startDate
        {% endset %}

        {% set results = run_query(query) %}
        {% set date = results.columns[0].values()[0] %}
    {% else %}
        set date = '1900-01-01'
    {% endif %}
    
    {{ return(date) }}
{% endmacro %}