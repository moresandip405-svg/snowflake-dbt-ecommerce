-- This test verifies that after discounts, net sales amount is never negative.
-- If any rows are returned, dbt test fails.
select
    order_key,
    gross_sales_amount,
    net_sales_amount
from {{ ref('fct_orders') }}
where net_sales_amount < 0
