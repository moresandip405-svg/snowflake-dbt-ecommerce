with customers as (
    select * from {{ ref('stg_tpch__customers') }}
),

orders as (
    select * from {{ ref('stg_tpch__orders') }}
),

order_metrics as (
    select * from {{ ref('int_order_items_aggregated') }}
),

customer_orders_aggregated as (
    select
        orders.customer_key,
        min(orders.order_date) as first_order_date,
        max(orders.order_date) as most_recent_order_date,
        count(distinct orders.order_key) as lifetime_order_count,
        round(coalesce(sum(order_metrics.net_sales_amount), 0), 2) as lifetime_net_spend
    from orders
    inner join order_metrics
        on orders.order_key = order_metrics.order_key
    group by orders.customer_key
),

final as (
    select
        customers.customer_key,
        customers.customer_name,
        customers.market_segment,
        customers.phone_number,
        customers.account_balance,

        coalesce(customer_orders_aggregated.lifetime_order_count, 0) as lifetime_order_count,
        coalesce(customer_orders_aggregated.lifetime_net_spend, 0) as lifetime_net_spend,
        customer_orders_aggregated.first_order_date,
        customer_orders_aggregated.most_recent_order_date,

        case 
            when customer_orders_aggregated.lifetime_order_count > 0 then 'Active'
            else 'Prospect'
        end as customer_status,

        current_timestamp() as dbt_updated_at

    from customers
    left join customer_orders_aggregated
        on customers.customer_key = customer_orders_aggregated.customer_key
)

select * from final
