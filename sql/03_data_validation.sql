-- ============================================================
-- E-Commerce 360° Analytics
-- File: 03_data_validation.sql
-- Purpose: Validate loaded data and check data quality
-- Database: Oracle Database 21c XE
-- ============================================================

SET ECHO ON
SET FEEDBACK ON
SET LINESIZE 200
SET PAGESIZE 100
SET SQLBLANKLINES ON

PROMPT ============================================================
PROMPT DATA VALIDATION STARTED
PROMPT ============================================================


-- ============================================================
-- 1. ROW COUNTS
-- ============================================================

PROMPT
PROMPT 1. ROW COUNTS
PROMPT ------------------------------------------------------------

SELECT 'CUSTOMERS' AS table_name, COUNT(*) AS row_count
FROM customers
UNION ALL
SELECT 'ORDERS', COUNT(*)
FROM orders
UNION ALL
SELECT 'PRODUCTS', COUNT(*)
FROM products
UNION ALL
SELECT 'SELLERS', COUNT(*)
FROM sellers
UNION ALL
SELECT 'ORDER_ITEMS', COUNT(*)
FROM order_items
UNION ALL
SELECT 'ORDER_PAYMENTS', COUNT(*)
FROM order_payments
UNION ALL
SELECT 'ORDER_REVIEWS', COUNT(*)
FROM order_reviews
UNION ALL
SELECT 'CATEGORY_TRANSLATION', COUNT(*)
FROM product_category_translation
UNION ALL
SELECT 'GEOLOCATION', COUNT(*)
FROM geolocation;


-- ============================================================
-- 2. CUSTOMERS VALIDATION
-- ============================================================

PROMPT
PROMPT 2. CUSTOMERS VALIDATION
PROMPT ------------------------------------------------------------

SELECT
    COUNT(*) AS total_customers,
    COUNT(customer_id) AS customer_ids,
    COUNT(customer_unique_id) AS unique_ids,
    COUNT(customer_city) AS cities,
    COUNT(customer_state) AS states
FROM customers;


-- Check duplicate customer IDs

SELECT customer_id, COUNT(*) AS duplicate_count
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;


-- ============================================================
-- 3. ORDERS VALIDATION
-- ============================================================

PROMPT
PROMPT 3. ORDERS VALIDATION
PROMPT ------------------------------------------------------------

SELECT
    COUNT(*) AS total_orders,
    COUNT(order_id) AS order_ids,
    COUNT(customer_id) AS customer_ids,
    COUNT(order_purchase_timestamp) AS purchase_dates,
    COUNT(order_status) AS order_statuses
FROM orders;


-- Orders without a customer

SELECT COUNT(*) AS orphan_orders
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;


-- ============================================================
-- 4. PRODUCTS VALIDATION
-- ============================================================

PROMPT
PROMPT 4. PRODUCTS VALIDATION
PROMPT ------------------------------------------------------------

SELECT
    COUNT(*) AS total_products,
    COUNT(product_id) AS product_ids,
    COUNT(product_category_name) AS categories
FROM products;


-- Duplicate product IDs

SELECT product_id, COUNT(*) AS duplicate_count
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;


-- ============================================================
-- 5. SELLERS VALIDATION
-- ============================================================

PROMPT
PROMPT 5. SELLERS VALIDATION
PROMPT ------------------------------------------------------------

SELECT
    COUNT(*) AS total_sellers,
    COUNT(seller_id) AS seller_ids,
    COUNT(seller_city) AS cities,
    COUNT(seller_state) AS states
FROM sellers;


-- Duplicate seller IDs

SELECT seller_id, COUNT(*) AS duplicate_count
FROM sellers
GROUP BY seller_id
HAVING COUNT(*) > 1;


-- ============================================================
-- 6. ORDER ITEMS VALIDATION
-- ============================================================

PROMPT
PROMPT 6. ORDER ITEMS VALIDATION
PROMPT ------------------------------------------------------------

SELECT
    COUNT(*) AS total_order_items,
    COUNT(product_id) AS products,
    COUNT(seller_id) AS sellers,
    COUNT(price) AS prices,
    COUNT(freight_value) AS freight_values
FROM order_items;


-- Order items without valid orders

SELECT COUNT(*) AS orphan_order_items
FROM order_items oi
LEFT JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;


-- Order items without valid products

SELECT COUNT(*) AS orphan_products
FROM order_items oi
LEFT JOIN products p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;


-- Order items without valid sellers

SELECT COUNT(*) AS orphan_sellers
FROM order_items oi
LEFT JOIN sellers s
    ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL;


-- Check negative prices

SELECT COUNT(*) AS negative_prices
FROM order_items
WHERE price < 0;


-- Check negative freight values

SELECT COUNT(*) AS negative_freight
FROM order_items
WHERE freight_value < 0;


-- ============================================================
-- 7. ORDER PAYMENTS VALIDATION
-- ============================================================

PROMPT
PROMPT 7. ORDER PAYMENTS VALIDATION
PROMPT ------------------------------------------------------------

SELECT
    COUNT(*) AS total_payments,
    COUNT(order_id) AS order_ids,
    COUNT(payment_type) AS payment_types,
    COUNT(payment_value) AS payment_values
FROM order_payments;


-- Payments without valid orders

SELECT COUNT(*) AS orphan_payments
FROM order_payments op
LEFT JOIN orders o
    ON op.order_id = o.order_id
WHERE o.order_id IS NULL;


-- Check negative payment values

SELECT COUNT(*) AS negative_payments
FROM order_payments
WHERE payment_value < 0;


-- ============================================================
-- 8. ORDER REVIEWS VALIDATION
-- ============================================================

PROMPT
PROMPT 8. ORDER REVIEWS VALIDATION
PROMPT ------------------------------------------------------------

SELECT
    COUNT(*) AS total_reviews,
    COUNT(review_id) AS review_ids,
    COUNT(order_id) AS order_ids,
    COUNT(review_score) AS review_scores
FROM order_reviews;


-- Reviews without valid orders

SELECT COUNT(*) AS orphan_reviews
FROM order_reviews r
LEFT JOIN orders o
    ON r.order_id = o.order_id
WHERE o.order_id IS NULL;


-- Check invalid review scores

SELECT COUNT(*) AS invalid_review_scores
FROM order_reviews
WHERE review_score < 1
   OR review_score > 5;


-- ============================================================
-- 9. CATEGORY TRANSLATION VALIDATION
-- ============================================================

PROMPT
PROMPT 9. CATEGORY TRANSLATION VALIDATION
PROMPT ------------------------------------------------------------

SELECT
    COUNT(*) AS total_categories,
    COUNT(product_category_name) AS portuguese_categories,
    COUNT(product_category_name_english) AS english_categories
FROM product_category_translation;


-- ============================================================
-- 10. GEOLOCATION VALIDATION
-- ============================================================

PROMPT
PROMPT 10. GEOLOCATION VALIDATION
PROMPT ------------------------------------------------------------

SELECT
    COUNT(*) AS total_geolocation_records,
    COUNT(geolocation_zip_code_prefix) AS zip_codes,
    COUNT(geolocation_lat) AS latitudes,
    COUNT(geolocation_lng) AS longitudes
FROM geolocation;


-- Check invalid latitude

SELECT COUNT(*) AS invalid_latitudes
FROM geolocation
WHERE geolocation_lat < -90
   OR geolocation_lat > 90;


-- Check invalid longitude

SELECT COUNT(*) AS invalid_longitudes
FROM geolocation
WHERE geolocation_lng < -180
   OR geolocation_lng > 180;


-- ============================================================
-- 11. ORDER DATE VALIDATION
-- ============================================================

PROMPT
PROMPT 11. ORDER DATE VALIDATION
PROMPT ------------------------------------------------------------

-- Approved date before purchase date

SELECT COUNT(*) AS invalid_approval_dates
FROM orders
WHERE order_approved_at < order_purchase_timestamp;


-- Delivered date before purchase date

SELECT COUNT(*) AS invalid_delivery_dates
FROM orders
WHERE order_delivered_customer_date < order_purchase_timestamp;


-- Estimated delivery before purchase date

SELECT COUNT(*) AS invalid_estimated_dates
FROM orders
WHERE order_estimated_delivery_date < order_purchase_timestamp;


-- ============================================================
-- 12. NULL PRIMARY KEYS CHECK
-- ============================================================

PROMPT
PROMPT 12. PRIMARY KEY NULL CHECK
PROMPT ------------------------------------------------------------

SELECT 'CUSTOMERS' AS table_name, COUNT(*) AS null_primary_keys
FROM customers
WHERE customer_id IS NULL
UNION ALL
SELECT 'ORDERS', COUNT(*)
FROM orders
WHERE order_id IS NULL
UNION ALL
SELECT 'PRODUCTS', COUNT(*)
FROM products
WHERE product_id IS NULL
UNION ALL
SELECT 'SELLERS', COUNT(*)
FROM sellers
WHERE seller_id IS NULL
UNION ALL
SELECT 'ORDER_REVIEWS', COUNT(*)
FROM order_reviews
WHERE review_id IS NULL OR order_id IS NULL;


-- ============================================================
-- VALIDATION COMPLETE
-- ============================================================

PROMPT
PROMPT ============================================================
PROMPT DATA VALIDATION COMPLETED
PROMPT ============================================================