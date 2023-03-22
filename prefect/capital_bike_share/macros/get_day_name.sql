 {#
    This macro returns the name of days of week 
#}

{% macro get_day_name(day_of_week) -%}

    case {{ day_of_week }}
        when 1 then 'Sunday'
        when 2 then 'Monday'
        when 3 then 'Tuesday'
        when 4 then 'Wednesday'
        when 5 then 'Thursday'
        when 6 then 'Friday'
        when 7 then 'Saturday'
    end

{%- endmacro %}