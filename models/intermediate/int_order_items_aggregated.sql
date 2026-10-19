with line_items as (
    select * from {{ ref('stg_tpch__line_items') }}
),

item_level_calculations as (
    select
        order_key,
        quantity,
        gross_price,
        gross_price * (1 - discount_percentage) as net_price,
        gross_price * discount_percentage as discount_amount,
        gross_price * (1 - discount_percentage) * (1 + tax_rate) as total_amount_with_tax
    from line_items
),

aggregated as (
    select
        order_key,
        count(*) as total_items_count,
        sum(quantity) as total_quantity_ordered,
        round(sum(gross_price), 2) as gross_sales_amount,
        round(sum(net_price), 2) as net_sales_amount,
        round(sum(discount_amount), 2) as total_discount_amount,
        round(sum(total_amount_with_tax), 2) as total_billed_amount
    from item_level_calculations
    group by order_key
)

select * from aggregated
