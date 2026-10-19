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
        {{ cents_to_dollars('sum(gross_price)') }} as gross_sales_amount,
        {{ cents_to_dollars('sum(net_price)') }} as net_sales_amount,
        {{ cents_to_dollars('sum(discount_amount)') }} as total_discount_amount,
        {{ cents_to_dollars('sum(total_amount_with_tax)') }} as total_billed_amount
    from item_level_calculations
    group by order_key
)

select * from aggregated
