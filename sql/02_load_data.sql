-- ============================================================
-- E-Commerce 360° Analytics
-- File: 02_load_data.sql
-- Purpose: Ingest cleaned CSV data into Oracle Database 21c XE & Verify Row Counts
-- Database: Oracle Database 21c XE
-- Target Schema: ECOMMERCE360
-- ============================================================

SET ECHO ON
SET FEEDBACK ON
SET LINESIZE 200
SET PAGESIZE 100

PROMPT ============================================================
PROMPT E-COMMERCE 360° - DATA INGESTION & LOADING PIPELINE
PROMPT ============================================================

PROMPT 
PROMPT [INFO] Data files are located in: data/processed/
PROMPT [INFO] SQL*Loader Control Files are located in: sql/ctl/
PROMPT
PROMPT To execute SQL*Loader batch ingestion from Windows PowerShell / CMD:
PROMPT ------------------------------------------------------------
PROMPT sqlldr userid=ECOMMERCE360/ecommerce360@localhost:1521/xepdb1 control=sql\ctl\01_customers.ctl log=sql\ctl\01_customers.log
PROMPT sqlldr userid=ECOMMERCE360/ecommerce360@localhost:1521/xepdb1 control=sql\ctl\02_orders.ctl log=sql\ctl\02_orders.log
PROMPT sqlldr userid=ECOMMERCE360/ecommerce360@localhost:1521/xepdb1 control=sql\ctl\03_products.ctl log=sql\ctl\03_products.log
PROMPT sqlldr userid=ECOMMERCE360/ecommerce360@localhost:1521/xepdb1 control=sql\ctl\04_sellers.ctl log=sql\ctl\04_sellers.log
PROMPT sqlldr userid=ECOMMERCE360/ecommerce360@localhost:1521/xepdb1 control=sql\ctl\05_order_items.ctl log=sql\ctl\05_order_items.log
PROMPT sqlldr userid=ECOMMERCE360/ecommerce360@localhost:1521/xepdb1 control=sql\ctl\06_order_payments.ctl log=sql\ctl\06_order_payments.log
PROMPT sqlldr userid=ECOMMERCE360/ecommerce360@localhost:1521/xepdb1 control=sql\ctl\07_order_reviews.ctl log=sql\ctl\07_order_reviews.log bad=sql\ctl\order_reviews.bad errors=50000 bindsize=1048576 rows=1000
PROMPT sqlldr userid=ECOMMERCE360/ecommerce360@localhost:1521/xepdb1 control=sql\ctl\08_category_translation.ctl log=sql\ctl\08_category_translation.log
PROMPT sqlldr userid=ECOMMERCE360/ecommerce360@localhost:1521/xepdb1 control=sql\ctl\09_geolocation.ctl log=sql\ctl\09_geolocation.log
PROMPT ------------------------------------------------------------
PROMPT

PROMPT ============================================================
PROMPT VERIFYING INGESTED ROW COUNTS ACROSS ALL 9 TABLES
PROMPT ============================================================

SELECT 'CUSTOMERS' AS table_name, COUNT(*) AS loaded_rows, 99441 AS expected_rows
FROM customers
UNION ALL
SELECT 'ORDERS', COUNT(*), 99441
FROM orders
UNION ALL
SELECT 'PRODUCTS', COUNT(*), 32951
FROM products
UNION ALL
SELECT 'SELLERS', COUNT(*), 3095
FROM sellers
UNION ALL
SELECT 'ORDER_ITEMS', COUNT(*), 112650
FROM order_items
UNION ALL
SELECT 'ORDER_PAYMENTS', COUNT(*), 103886
FROM order_payments
UNION ALL
SELECT 'ORDER_REVIEWS', COUNT(*), 99224
FROM order_reviews
UNION ALL
SELECT 'PRODUCT_CATEGORY_TRANSLATION', COUNT(*), 71
FROM product_category_translation
UNION ALL
SELECT 'GEOLOCATION', COUNT(*), 738332
FROM geolocation;

PROMPT ============================================================
PROMPT DATA LOADING & VERIFICATION COMPLETED
PROMPT ============================================================