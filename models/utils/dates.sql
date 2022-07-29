{{ config(cluster_by='date') }}

{%- set week_date_part = 'isoweek' if target.type == 'bigquery' else 'week' -%}

with
    date_spine as (
        {{ dbt_utils.date_spine(
            datepart="day"
            , start_date="cast('2001-01-01' as date)"
            , end_date="cast('2100-12-31' as date)"
        ) }}
    )
    , extracts as (
        select
            cast(date_day as date) as date
            , extract(day from date_day) as day_of_month
            , extract(dayofyear from date_day) as day_of_year
            , extract({{ week_date_part }} from date_day) as week_of_year
            , extract(month from date_day) as month_of_year
            , extract(quarter from date_day) as quarter_of_year
            , extract(year from date_day) as year
        from date_spine
    )
    , precalculations_1 as (
        select
            *
            , cast({{ dbt_utils.date_trunc(week_date_part, 'date') }} as date) as week_start_date
        from extracts
    )
    , precalculations_2 as (
        select
            *
            , {{ dbt_utils.datediff('week_start_date', 'date', 'day') }} + 1 as day_of_week
        from precalculations_1
    )

select
    /* Primary key */
    date

    /* Timestamps and properties */
    , day_of_week
    , case day_of_week
        when 1 then 'Monday'
        when 2 then 'Tuesday'
        when 3 then 'Wednesday'
        when 4 then 'Thursday'
        when 5 then 'Friday'
        when 6 then 'Saturday'
        when 7 then 'Sunday'
      end as day_of_week_name
    , day_of_month
    , day_of_year

    , week_of_year
    , case
        when month_of_year = 1 and week_of_year >= 52 then year - 1
        when month_of_year = 12 and week_of_year = 1 then year + 1
        else year
      end as year_of_week
    , week_start_date
    , cast({{ dbt_utils.dateadd('day', 6, 'week_start_date') }} as date) as week_end_date

    , month_of_year
    , case month_of_year
        when 1 then 'January'
        when 2 then 'February'
        when 3 then 'March'
        when 4 then 'April'
        when 5 then 'May'
        when 6 then 'June'
        when 7 then 'July'
        when 8 then 'August'
        when 9 then 'September'
        when 10 then 'October'
        when 11 then 'November'
        when 12 then 'December'
      end as month_of_year_name
    , cast({{ dbt_utils.date_trunc('month', 'date') }} as date) as month_start_date
    , cast({{ dbt_utils.last_day('date', 'month') }} as date) as month_end_date

    , quarter_of_year
    , cast({{ dbt_utils.date_trunc('quarter', 'date') }} as date) as quarter_start_date
    , cast({{ dbt_utils.last_day('date', 'quarter') }} as date) as quarter_end_date

    , year
    , cast({{ dbt_utils.date_trunc('year', 'date') }} as date) as year_start_date
    , cast({{ dbt_utils.last_day('date', 'year') }} as date) as year_end_date

from precalculations_2
