# 🛍️ Snowflake + dbt E-Commerce Analytics Platform

> Production-ready modern data transformation pipeline built with **Snowflake** and **dbt-core**, modeling raw TPC-H transactional data into a high-performance Kimball Star Schema.

---

## 🏗️ End-to-End System Architecture

```text
 ┌────────────────────────────────────────────────────────────────────────┐
 │                      RAW DATA SOURCES (Snowflake)                      │
 │                 Database: SNOWFLAKE_SAMPLE_DATA.TPCH_SF1               │
 │            ├── CUSTOMER       ├── ORDERS       ├── LINEITEM            │
 └───────────────────────────────────┬────────────────────────────────────┘
                                     │
                                     ▼ (dbt-core / DBT_DEV_ROLE)
 ┌────────────────────────────────────────────────────────────────────────┐
 │                      TRANSFORMATION ENGINE (dbt)                       │
 │                                                                        │
 │  LAYER 1: STAGING (Bronze) ➔ Materialized: VIEW                        │
 │  ├── stg_tpch__customers.sql  (1:1 rename, datatype casting)           │
 │  ├── stg_tpch__orders.sql     (Status codes, clean dates)              │
 │  └── stg_tpch__line_items.sql (Surrogate keys via dbt_utils)           │
 │                                   │                                    │
 │                                   ▼                                    │
 │  LAYER 2: INTERMEDIATE (Silver) ➔ Materialized: TABLE                  │
 │  └── int_order_items_aggregated.sql (Item rollups, net sales, taxes)   │
 │                                   │                                    │
 │                                   ▼                                    │
 │  LAYER 3: MARTS (Gold - Star Schema)                                   │
 │  ├── dim_customers.sql ➔ TABLE (Customer lifetime spend & status)     │
 │  └── fct_orders.sql     ➔ INCREMENTAL (Order metrics, fulfillment)     │
 └───────────────────────────────────┬────────────────────────────────────┘
                                     │
                                     ▼ (SQL / BI Layer)
 ┌────────────────────────────────────────────────────────────────────────┐
 │                    BUSINESS CONSUMPTION & METRICS                      │
 │      ├── Customer Lifetime Value (LTV)    ├── Discount Margin Impact   │
 │      ├── Average Order Value (AOV)        ├── Order Fulfillment Rate   │
 └────────────────────────────────────────────────────────────────────────┘
