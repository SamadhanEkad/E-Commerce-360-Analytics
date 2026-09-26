-- ============================================================
-- E-Commerce 360° Analytics
-- File: 06_customer_analysis.sql
-- Purpose: Customer behavior and customer value analysis
-- Database: Oracle Database 21c XE
-- ============================================================

SET ECHO ON
SET FEEDBACK ON
SET LINESIZE 200
SET PAGESIZE 100
SET SQLBLANKLINES ON

PROMPT ============================================================
PROMPT E-COMMERCE 360° - CUSTOMER ANALYSIS
PROMPT ============================================================


-- ============================================================
-- 1. CUSTOMERS BY STATE
-- ============================================================

PROMPT
PROMPT 1. CUSTOMERS BY STATE
PROMPT ------------------------------------------------------------

SELECT
    customer_state,
    COUNT(*) AS total_customers
FROM customers
GROUP BY customer_state
ORDER BY total_customers DESC;


-- ============================================================
-- 2. CUSTOMERS BY CITY
-- ============================================================

PROMPT
PROMPT 2. TOP 20 CITIES BY CUSTOMER COUNT
PROMPT ------------------------------------------------------------

SELECT *
FROM (
    SELECT
        customer_city,
        customer_state,
        COUNT(*) AS total_customers
    FROM customers
    GROUP BY customer_city, customer_state
    ORDER BY total_customers DESC
)
WHERE ROWNUM <= 20;


-- ============================================================
-- 3. ACTIVE CUSTOMERS BY STATE
-- ============================================================

PROMPT
PROMPT 3. ACTIVE CUSTOMERS BY STATE
PROMPT ------------------------------------------------------------

SELECT
    c.customer_state,
    COUNT(DISTINCT c.customer_id) AS active_customers,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_state
ORDER BY active_customers DESC;


-- ============================================================
-- 4. ORDERS PER CUSTOMER
-- ============================================================

PROMPT
PROMPT 4. ORDERS PER CUSTOMER
PROMPT ------------------------------------------------------------

SELECT
    ROUND(
        COUNT(DISTINCT o.order_id) * 1.0 / COUNT(DISTINCT c.customer_unique_id),
        2
    ) AS average_orders_per_customer
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id;


-- ============================================================
-- 5. CUSTOMER ORDER FREQUENCY
-- ============================================================

PROMPT
PROMPT 5. CUSTOMER ORDER FREQUENCY
PROMPT ------------------------------------------------------------

SELECT
    order_frequency,
    COUNT(*) AS customer_count,
    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(DISTINCT customer_unique_id) FROM customers),
        2
    ) AS percentage
FROM (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_frequency
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
)
GROUP BY order_frequency
ORDER BY order_frequency;


-- ============================================================
-- 6. ONE-TIME VS REPEAT CUSTOMERS
-- ============================================================

PROMPT
PROMPT 6. ONE-TIME VS REPEAT CUSTOMERS
PROMPT ------------------------------------------------------------

SELECT
    CASE
        WHEN order_count = 1 THEN 'One-Time Customer'
        ELSE 'Repeat Customer'
    END AS customer_type,
    COUNT(*) AS customer_count,
    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(DISTINCT customer_unique_id) FROM customers),
        2
    ) AS percentage
FROM (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
)
GROUP BY
    CASE
        WHEN order_count = 1 THEN 'One-Time Customer'
        ELSE 'Repeat Customer'
    END;


-- ============================================================
-- 7. REPEAT CUSTOMER RATE
-- ============================================================

PROMPT
PROMPT 7. REPEAT CUSTOMER RATE
PROMPT ------------------------------------------------------------

SELECT
    ROUND(
        SUM(
            CASE
                WHEN order_count > 1 THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS repeat_customer_rate_percentage
FROM (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
);


-- ============================================================
-- 8. TOP 20 CUSTOMERS BY REVENUE
-- ============================================================

PROMPT
PROMPT 8. TOP 20 CUSTOMERS BY REVENUE
PROMPT ------------------------------------------------------------

SELECT *
FROM (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders,
        ROUND(SUM(oi.price), 2) AS revenue,
        ROUND(SUM(oi.freight_value), 2) AS freight,
        ROUND(SUM(oi.price + oi.freight_value), 2) AS total_value
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_unique_id
    ORDER BY revenue DESC
)
WHERE ROWNUM <= 20;


-- ============================================================
-- 9. CUSTOMER AVERAGE ORDER VALUE
-- ============================================================

PROMPT
PROMPT 9. CUSTOMER AVERAGE ORDER VALUE (REPEAT BUYERS)
PROMPT ------------------------------------------------------------

SELECT *
FROM (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders,
        ROUND(SUM(oi.price), 2) AS revenue,
        ROUND(SUM(oi.price) / COUNT(DISTINCT o.order_id), 2) AS average_order_value
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_unique_id
    HAVING COUNT(DISTINCT o.order_id) > 1
    ORDER BY revenue DESC
)
WHERE ROWNUM <= 20;


-- ============================================================
-- 10. CUSTOMER SPENDING SEGMENTS
-- ============================================================

PROMPT
PROMPT 10. CUSTOMER SPENDING SEGMENTS
PROMPT ------------------------------------------------------------

SELECT
    spending_segment,
    COUNT(*) AS customer_count,
    ROUND(AVG(revenue), 2) AS average_revenue
FROM (
    SELECT
        c.customer_unique_id,
        SUM(oi.price) AS revenue,
        CASE
            WHEN SUM(oi.price) < 100 THEN 'Low Value (< 100)'
            WHEN SUM(oi.price) < 500 THEN 'Medium Value (100 - 499)'
            WHEN SUM(oi.price) < 1000 THEN 'High Value (500 - 999)'
            ELSE 'Very High Value (1000+)'
        END AS spending_segment
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_unique_id
)
GROUP BY spending_segment
ORDER BY average_revenue DESC;


-- ============================================================
-- 11. TOP 20 CUSTOMERS BY ORDER COUNT
-- ============================================================

PROMPT
PROMPT 11. TOP 20 CUSTOMERS BY ORDER COUNT
PROMPT ------------------------------------------------------------

SELECT *
FROM (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders,
        ROUND(SUM(oi.price), 2) AS total_spent
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_unique_id
    ORDER BY total_orders DESC, total_spent DESC
)
WHERE ROWNUM <= 20;


-- ============================================================
-- 12. CUSTOMER REVENUE BY STATE
-- ============================================================

PROMPT
PROMPT 12. CUSTOMER REVENUE BY STATE
PROMPT ------------------------------------------------------------

SELECT
    c.customer_state,
    COUNT(DISTINCT c.customer_id) AS customers,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(SUM(oi.price), 2) AS revenue,
    ROUND(
        SUM(oi.price) / COUNT(DISTINCT c.customer_id),
        2
    ) AS revenue_per_customer
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY revenue DESC;


-- ============================================================
-- 13. CUSTOMER ORDER VALUE
-- ============================================================

PROMPT
PROMPT 13. CUSTOMER ORDER VALUE DISTRIBUTION
PROMPT ------------------------------------------------------------

SELECT
    CASE
        WHEN average_order_value < 50 THEN 'Under 50'
        WHEN average_order_value < 100 THEN '50 - 99'
        WHEN average_order_value < 250 THEN '100 - 249'
        WHEN average_order_value < 500 THEN '250 - 499'
        ELSE '500+'
    END AS value_range,
    COUNT(*) AS customer_count
FROM (
    SELECT
        c.customer_unique_id,
        SUM(oi.price) / COUNT(DISTINCT o.order_id) AS average_order_value
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_unique_id
)
GROUP BY
    CASE
        WHEN average_order_value < 50 THEN 'Under 50'
        WHEN average_order_value < 100 THEN '50 - 99'
        WHEN average_order_value < 250 THEN '100 - 249'
        WHEN average_order_value < 500 THEN '250 - 499'
        ELSE '500+'
    END
ORDER BY customer_count DESC;


-- ============================================================
-- 14. CUSTOMER PURCHASE PERIOD (LIFESPAN OF REPEAT BUYERS)
-- ============================================================

PROMPT
PROMPT 14. CUSTOMER PURCHASE PERIOD (TOP REPEAT BUYERS)
PROMPT ------------------------------------------------------------

SELECT *
FROM (
    SELECT
        c.customer_unique_id,
        MIN(o.order_purchase_timestamp) AS first_order_date,
        MAX(o.order_purchase_timestamp) AS last_order_date,
        COUNT(DISTINCT o.order_id) AS total_orders,
        ROUND(
            CAST(MAX(o.order_purchase_timestamp) AS DATE) -
            CAST(MIN(o.order_purchase_timestamp) AS DATE)
        ) AS lifespan_days
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
    HAVING COUNT(DISTINCT o.order_id) > 1
    ORDER BY lifespan_days DESC
)
WHERE ROWNUM <= 20;


-- ============================================================
-- 15. MONTHLY ACTIVE UNIQUE CUSTOMERS
-- ============================================================

PROMPT
PROMPT 15. MONTHLY ACTIVE UNIQUE CUSTOMERS
PROMPT ------------------------------------------------------------

SELECT
    TO_CHAR(o.order_purchase_timestamp, 'YYYY-MM') AS order_month,
    COUNT(DISTINCT c.customer_unique_id) AS active_unique_customers,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
WHERE o.order_purchase_timestamp IS NOT NULL
GROUP BY TO_CHAR(o.order_purchase_timestamp, 'YYYY-MM')
ORDER BY order_month;


-- ============================================================
-- 16. CUSTOMER REVENUE RANKING
-- ============================================================

PROMPT
PROMPT 16. CUSTOMER REVENUE RANKING
PROMPT ------------------------------------------------------------

SELECT
    customer_unique_id,
    revenue,
    DENSE_RANK() OVER (ORDER BY revenue DESC) AS revenue_rank
FROM (
    SELECT
        c.customer_unique_id,
        ROUND(SUM(oi.price), 2) AS revenue
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_unique_id
)
ORDER BY revenue_rank
FETCH FIRST 20 ROWS ONLY;


-- ============================================================
-- 17. CUSTOMER REVENUE CONTRIBUTION (TOP 10% DECILE)
-- ============================================================

PROMPT
PROMPT 17. TOP 10 PERCENT CUSTOMER REVENUE CONTRIBUTION
PROMPT ------------------------------------------------------------

SELECT
    ROUND(
        SUM(
            CASE
                WHEN customer_rank <= total_customers * 0.10
                THEN revenue
                ELSE 0
            END
        ),
        2
    ) AS top_10_percent_revenue,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(
        SUM(
            CASE
                WHEN customer_rank <= total_customers * 0.10
                THEN revenue
                ELSE 0
            END
        ) * 100 / SUM(revenue),
        2
    ) AS revenue_percentage
FROM (
    SELECT
        c.customer_unique_id,
        revenue,
        ROW_NUMBER() OVER (ORDER BY revenue DESC) AS customer_rank,
        COUNT(*) OVER () AS total_customers
    FROM (
        SELECT
            c.customer_unique_id,
            SUM(oi.price) AS revenue
        FROM orders o
        JOIN customers c
            ON o.customer_id = c.customer_id
        JOIN order_items oi
            ON o.order_id = oi.order_id
        GROUP BY c.customer_unique_id
    ) c
);


-- ============================================================
-- 18. CUSTOMERS WITH MULTIPLE ORDERS (REPEAT BUYERS COUNT)
-- ============================================================

PROMPT
PROMPT 18. CUSTOMERS WITH MULTIPLE ORDERS
PROMPT ------------------------------------------------------------

SELECT
    COUNT(*) AS repeat_customers_count
FROM (
    SELECT
        c.customer_unique_id
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
    HAVING COUNT(DISTINCT o.order_id) > 1
);


-- ============================================================
-- 19. CUSTOMERS WITH ONLY CANCELLED ORDERS
-- ============================================================

PROMPT
PROMPT 19. CUSTOMERS WITH ONLY CANCELLED ORDERS
PROMPT ------------------------------------------------------------

SELECT
    COUNT(*) AS customers_only_cancelled
FROM (
    SELECT
        c.customer_unique_id
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
    HAVING COUNT(*) =
           SUM(
               CASE
                   WHEN o.order_status = 'canceled'
                   THEN 1
                   ELSE 0
               END
           )
);


-- ============================================================
-- 20. CUSTOMER REVIEW SCORE BY REPEAT STATUS
-- ============================================================

PROMPT
PROMPT 20. AVERAGE REVIEW SCORE: ONE-TIME VS REPEAT BUYERS
PROMPT ------------------------------------------------------------

SELECT
    CASE
        WHEN order_count = 1 THEN 'One-Time Buyer'
        ELSE 'Repeat Buyer'
    END AS buyer_type,
    COUNT(DISTINCT customer_unique_id) AS buyer_count,
    ROUND(AVG(review_score), 2) AS average_review_score
FROM (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count,
        AVG(r.review_score) AS review_score
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    JOIN order_reviews r
        ON o.order_id = r.order_id
    GROUP BY c.customer_unique_id
)
GROUP BY
    CASE
        WHEN order_count = 1 THEN 'One-Time Buyer'
        ELSE 'Repeat Buyer'
    END;


-- ============================================================
-- CUSTOMER ANALYSIS COMPLETE
-- ============================================================

PROMPT
PROMPT ============================================================
PROMPT CUSTOMER ANALYSIS COMPLETED
PROMPT ============================================================