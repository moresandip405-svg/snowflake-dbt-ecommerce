with source as (
    select * from {{ source('tpch_sf1', 'customer') }}
),

renamed as (
    select
        c_custkey as customer_key,
        c_name as customer_name,
        c_address as street_address,
        c_nationkey as nation_key,
        c_phone as phone_number,
        c_acctbal as account_balance,
        c_mktsegment as market_segment,
        c_comment as comment
    from source
)

select * from renamed
