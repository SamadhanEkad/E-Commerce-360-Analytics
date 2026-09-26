-- ============================================================
-- E-Commerce 360° Analytics
-- File: 04_kpi_analysis.sql
-- Purpose: Calculate core business KPIs
-- Database: Oracle Database 21c XE
-- ============================================================

SET ECHO ON
SET FEEDBACK ON
SET LINESIZE 200
SET PAGESIZE 100
SET SQLBLANKLINES ON

PROMPT ============================================================
PROMPT E-COMMERCE 360° - KPI ANALYSIS
PROMPT ============================================================


-- ============================================================
-- 1. TOTAL CUSTOMERS
-- ============================================================

PROMPT
PROMPT 1. TOTAL CUSTOMERS
PROMPT ------------------------------------------------------------

SELECT COUNT(*) AS total_customers
FROM customers;


-- ============================================================
-- 2. TOTAL ORDERS
-- ============================================================

PROMPT
PROMPT 2. TOTAL ORDERS
PROMPT ------------------------------------------------------------

SELECT COUNT(*) AS total_orders
FROM orders;


-- ============================================================
-- 3. TOTAL PRODUCTS
-- ============================================================

PROMPT
PROMPT 3. TOTAL PRODUCTS
PROMPT ------------------------------------------------------------

SELECT COUNT(*) AS total_products
FROM products;


-- ============================================================
-- 4. TOTAL SELLERS
-- ============================================================

PROMPT
PROMPT 4. TOTAL SELLERS
PROMPT ------------------------------------------------------------

SELECT COUNT(*) AS total_sellers
FROM sellers;


-- ============================================================
-- 5. TOTAL ORDER ITEMS
-- ============================================================

PROMPT
PROMPT 5. TOTAL ORDER ITEMS
PROMPT ------------------------------------------------------------

SELECT COUNT(*) AS total_order_items
FROM order_items;


-- ============================================================
-- 6. TOTAL REVENUE
-- ============================================================

PROMPT
PROMPT 6. TOTAL REVENUE
PROMPT ------------------------------------------------------------

SELECT
    ROUND(SUM(price), 2) AS total_revenue
FROM order_items;


-- ============================================================
-- 7. TOTAL FREIGHT COST
-- ============================================================

PROMPT
PROMPT 7. TOTAL FREIGHT COST
PROMPT ------------------------------------------------------------

SELECT
    ROUND(SUM(freight_value), 2) AS total_freight_cost
FROM order_items;


-- ============================================================
-- 8. TOTAL ORDER VALUE INCLUDING FREIGHT
-- ============================================================

PROMPT
PROMPT 8. TOTAL ORDER VALUE INCLUDING FREIGHT
PROMPT ------------------------------------------------------------

SELECT
    ROUND(SUM(price + freight_value), 2) AS total_order_value
FROM order_items;


-- ============================================================
-- 9. AVERAGE ORDER VALUE
-- ============================================================

PROMPT
PROMPT 9. AVERAGE ORDER VALUE
PROMPT ------------------------------------------------------------

SELECT
    ROUND(SUM(price) / COUNT(DISTINCT order_id), 2)
        AS average_order_value
FROM order_items;


-- ============================================================
-- 10. AVERAGE FREIGHT PER ORDER
-- ============================================================

PROMPT
PROMPT 10. AVERAGE FREIGHT PER ORDER
PROMPT ------------------------------------------------------------

SELECT
    ROUND(SUM(freight_value) / COUNT(DISTINCT order_id), 2)
        AS average_freight_per_order
FROM order_items;


-- ============================================================
-- 11. AVERAGE REVIEW SCORE
-- ============================================================

PROMPT
PROMPT 11. AVERAGE REVIEW SCORE
PROMPT ------------------------------------------------------------

SELECT
    ROUND(AVG(review_score), 2) AS average_review_score
FROM order_reviews;


-- ============================================================
-- 12. ORDER STATUS DISTRIBUTION
-- ============================================================

PROMPT
PROMPT 12. ORDER STATUS DISTRIBUTION
PROMPT ------------------------------------------------------------

SELECT
    order_status,
    COUNT(*) AS order_count,
    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders),
        2
    ) AS percentage
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;


-- ============================================================
-- 13. DELIVERED ORDERS
-- ============================================================

PROMPT
PROMPT 13. DELIVERED ORDERS
PROMPT ------------------------------------------------------------

SELECT
    COUNT(*) AS delivered_orders
FROM orders
WHERE order_status = 'delivered';


-- ============================================================
-- 14. CANCELLED ORDERS
-- ============================================================

PROMPT
PROMPT 14. CANCELLED ORDERS
PROMPT ------------------------------------------------------------

SELECT
    COUNT(*) AS cancelled_orders
FROM orders
WHERE order_status = 'canceled';


-- ============================================================
-- 15. DELIVERY RATE
-- ============================================================

PROMPT
PROMPT 15. DELIVERY RATE
PROMPT ------------------------------------------------------------

SELECT
    ROUND(
        SUM(
            CASE
                WHEN order_status = 'delivered' THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS delivery_rate_percentage
FROM orders;


-- ============================================================
-- 16. CANCELLATION RATE
-- ============================================================

PROMPT
PROMPT 16. CANCELLATION RATE
PROMPT ------------------------------------------------------------

SELECT
    ROUND(
        SUM(
            CASE
                WHEN order_status = 'canceled' THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS cancellation_rate_percentage
FROM orders;


-- ============================================================
-- 17. UNIQUE CUSTOMERS WHO PLACED ORDERS
-- ============================================================

PROMPT
PROMPT 17. UNIQUE CUSTOMERS WHO PLACED ORDERS
PROMPT ------------------------------------------------------------

SELECT
    COUNT(DISTINCT c.customer_unique_id) AS active_unique_customers
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id;


-- ============================================================
-- 18. ORDERS PER CUSTOMER
-- ============================================================

PROMPT
PROMPT 18. ORDERS PER CUSTOMER
PROMPT ------------------------------------------------------------

SELECT
    ROUND(
        COUNT(DISTINCT o.order_id) * 1.0 / COUNT(DISTINCT c.customer_unique_id),
        2
    ) AS orders_per_customer
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id;


-- ============================================================
-- 19. PRODUCTS PER ORDER
-- ============================================================

PROMPT
PROMPT 19. PRODUCTS PER ORDER
PROMPT ------------------------------------------------------------

SELECT
    ROUND(
        COUNT(*) / COUNT(DISTINCT order_id),
        2
    ) AS items_per_order
FROM order_items;


-- ============================================================
-- 20. PAYMENT VALUE
-- ============================================================

PROMPT
PROMPT 20. TOTAL PAYMENT VALUE
PROMPT ------------------------------------------------------------

SELECT
    ROUND(SUM(payment_value), 2) AS total_payment_value
FROM order_payments;


-- ============================================================
-- 21. PAYMENT METHODS
-- ============================================================

PROMPT
PROMPT 21. PAYMENT METHOD DISTRIBUTION
PROMPT ------------------------------------------------------------

SELECT
    payment_type,
    COUNT(*) AS payment_count,
    ROUND(SUM(payment_value), 2) AS payment_value
FROM order_payments
GROUP BY payment_type
ORDER BY payment_value DESC;


-- ============================================================
-- 22. REVIEW SCORE DISTRIBUTION
-- ============================================================

PROMPT
PROMPT 22. REVIEW SCORE DISTRIBUTION
PROMPT ------------------------------------------------------------

SELECT
    review_score,
    COUNT(*) AS review_count,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM order_reviews),
        2
    ) AS percentage
FROM order_reviews
GROUP BY review_score
ORDER BY review_score;


-- ============================================================
-- 23. MONTHLY REVENUE
-- ============================================================

PROMPT
PROMPT 23. MONTHLY REVENUE
PROMPT ------------------------------------------------------------

SELECT
    TO_CHAR(
        o.order_purchase_timestamp,
        'YYYY-MM'
    ) AS order_month,
    ROUND(SUM(oi.price), 2) AS monthly_revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY TO_CHAR(
    o.order_purchase_timestamp,
    'YYYY-MM'
)
ORDER BY order_month;


-- ============================================================
-- 24. YEARLY REVENUE
-- ============================================================

PROMPT
PROMPT 24. YEARLY REVENUE
PROMPT ------------------------------------------------------------

SELECT
    EXTRACT(YEAR FROM o.order_purchase_timestamp) AS order_year,
    ROUND(SUM(oi.price), 2) AS yearly_revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY EXTRACT(YEAR FROM o.order_purchase_timestamp)
ORDER BY order_year;


-- ============================================================
-- 25. TOP 10 SELLERS BY REVENUE
-- ============================================================

PROMPT
PROMPT 25. TOP 10 SELLERS BY REVENUE
PROMPT ------------------------------------------------------------

SELECT *
FROM (
    SELECT
        seller_id,
        ROUND(SUM(price), 2) AS revenue
    FROM order_items
    GROUP BY seller_id
    ORDER BY revenue DESC
)
WHERE ROWNUM <= 10;


-- ============================================================
-- 26. TOP 10 PRODUCTS BY REVENUE
-- ============================================================

PROMPT
PROMPT 26. TOP 10 PRODUCTS BY REVENUE
PROMPT ------------------------------------------------------------

SELECT *
FROM (
    SELECT
        product_id,
        ROUND(SUM(price), 2) AS revenue
    FROM order_items
    GROUP BY product_id
    ORDER BY revenue DESC
)
WHERE ROWNUM <= 10;


-- ============================================================
-- KPI ANALYSIS COMPLETE
-- ============================================================

PROMPT
PROMPT ============================================================
PROMPT KPI ANALYSIS COMPLETED
PROMPT ============================================================