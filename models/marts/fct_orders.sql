{{
    config(
        materialized = 'incremental',
        unique_key = 'order_key',
        on_schema_change = 'fail'
    )
}}

with orders as (
    select * from {{ ref('stg_tpch__orders') }}
    {% if is_incremental() %}
        where order_date > (select max(order_date) from {{ this }})
    {% endif %}
),

order_items_summary as (
    select * from {{ ref('int_order_items_aggregated') }}
),

final as (
    select
        orders.order_key,
        orders.customer_key,
        orders.order_date,
        orders.order_status_code,
        orders.order_priority,

        coalesce(order_items_summary.total_items_count, 0) as total_items_count,
        coalesce(order_items_summary.total_quantity_ordered, 0) as total_quantity_ordered,
        coalesce(order_items_summary.gross_sales_amount, 0) as gross_sales_amount,
        coalesce(order_items_summary.net_sales_amount, 0) as net_sales_amount,
        coalesce(order_items_summary.total_discount_amount, 0) as total_discount_amount,
        coalesce(order_items_summary.total_billed_amount, 0) as total_billed_amount,

        case 
            when orders.order_status_code = 'F' then 'Fulfilled'
            when orders.order_status_code = 'O' then 'Open'
            when orders.order_status_code = 'P' then 'Partial'
            else 'Unknown'
        end as order_status_description,

        current_timestamp() as dbt_updated_at

    from orders
    left join order_items_summary
        on orders.order_key = order_items_summary.order_key
)

select * from final
