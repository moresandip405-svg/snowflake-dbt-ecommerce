with date_spine as (
    -- Generates a continuous daily series from 1992 to 1998 (TPC-H dataset range)
    select 
        dateadd(day, seq4(), '1992-01-01'::date) as date_day
    from table(generator(rowcount => 2600))
),

final as (
    select
        date_day,
        to_char(date_day, 'YYYYMMDD')::integer as date_key,
        year(date_day) as year_number,
        quarter(date_day) as quarter_number,
        month(date_day) as month_number,
        monthname(date_day) as month_name,
        dayofweek(date_day) as day_of_week_number,
        dayname(date_day) as day_of_week_name,
        case 
            when dayofweek(date_day) in (0, 6) then true 
            else false 
        end as is_weekend
    from date_spine
)

select * from final
