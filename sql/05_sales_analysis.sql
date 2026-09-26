-- ============================================================
-- E-Commerce 360° Analytics
-- File: 05_sales_analysis.sql
-- Purpose: Sales, product, category and seller analysis
-- Database: Oracle Database 21c XE
-- ============================================================

SET ECHO ON
SET FEEDBACK ON
SET LINESIZE 200
SET PAGESIZE 100
SET SQLBLANKLINES ON

PROMPT ============================================================
PROMPT E-COMMERCE 360° - SALES ANALYSIS
PROMPT ============================================================


-- ============================================================
-- 1. MONTHLY SALES PERFORMANCE
-- ============================================================

PROMPT
PROMPT 1. MONTHLY SALES PERFORMANCE
PROMPT ------------------------------------------------------------

SELECT
    TO_CHAR(
        o.order_purchase_timestamp,
        'YYYY-MM'
    ) AS order_month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(oi.order_id) AS total_items,
    ROUND(SUM(oi.price), 2) AS revenue,
    ROUND(SUM(oi.freight_value), 2) AS freight,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_sales
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY TO_CHAR(
    o.order_purchase_timestamp,
    'YYYY-MM'
)
ORDER BY order_month;


-- ============================================================
-- 2. YEARLY SALES PERFORMANCE
-- ============================================================

PROMPT
PROMPT 2. YEARLY SALES PERFORMANCE
PROMPT ------------------------------------------------------------

SELECT
    EXTRACT(YEAR FROM o.order_purchase_timestamp) AS order_year,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(oi.order_id) AS total_items,
    ROUND(SUM(oi.price), 2) AS revenue,
    ROUND(SUM(oi.freight_value), 2) AS freight,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_sales
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY EXTRACT(YEAR FROM o.order_purchase_timestamp)
ORDER BY order_year;


-- ============================================================
-- 3. TOP 10 PRODUCT CATEGORIES BY REVENUE
-- ============================================================

PROMPT
PROMPT 3. TOP 10 PRODUCT CATEGORIES BY REVENUE
PROMPT ------------------------------------------------------------

SELECT *
FROM (
    SELECT
        NVL(
            pct.product_category_name_english,
            p.product_category_name
        ) AS category,
        COUNT(DISTINCT oi.order_id) AS orders,
        COUNT(*) AS items_sold,
        ROUND(SUM(oi.price), 2) AS revenue
    FROM order_items oi
    JOIN products p
        ON oi.product_id = p.product_id
    LEFT JOIN product_category_translation pct
        ON p.product_category_name =
           pct.product_category_name
    GROUP BY
        NVL(
            pct.product_category_name_english,
            p.product_category_name
        )
    ORDER BY revenue DESC
)
WHERE ROWNUM <= 10;


-- ============================================================
-- 4. TOP 10 PRODUCT CATEGORIES BY ITEMS SOLD
-- ============================================================

PROMPT
PROMPT 4. TOP 10 PRODUCT CATEGORIES BY ITEMS SOLD
PROMPT ------------------------------------------------------------

SELECT *
FROM (
    SELECT
        NVL(
            pct.product_category_name_english,
            p.product_category_name
        ) AS category,
        COUNT(*) AS items_sold,
        ROUND(SUM(oi.price), 2) AS revenue
    FROM order_items oi
    JOIN products p
        ON oi.product_id = p.product_id
    LEFT JOIN product_category_translation pct
        ON p.product_category_name =
           pct.product_category_name
    GROUP BY
        NVL(
            pct.product_category_name_english,
            p.product_category_name
        )
    ORDER BY items_sold DESC
)
WHERE ROWNUM <= 10;


-- ============================================================
-- 5. TOP 10 PRODUCTS BY REVENUE
-- ============================================================

PROMPT
PROMPT 5. TOP 10 PRODUCTS BY REVENUE
PROMPT ------------------------------------------------------------

SELECT *
FROM (
    SELECT
        oi.product_id,
        NVL(
            pct.product_category_name_english,
            p.product_category_name
        ) AS category,
        COUNT(*) AS items_sold,
        ROUND(SUM(oi.price), 2) AS revenue
    FROM order_items oi
    JOIN products p
        ON oi.product_id = p.product_id
    LEFT JOIN product_category_translation pct
        ON p.product_category_name =
           pct.product_category_name
    GROUP BY
        oi.product_id,
        NVL(
            pct.product_category_name_english,
            p.product_category_name
        )
    ORDER BY revenue DESC
)
WHERE ROWNUM <= 10;


-- ============================================================
-- 6. TOP 10 SELLERS BY REVENUE
-- ============================================================

PROMPT
PROMPT 6. TOP 10 SELLERS BY REVENUE
PROMPT ------------------------------------------------------------

SELECT *
FROM (
    SELECT
        oi.seller_id,
        s.seller_city,
        s.seller_state,
        COUNT(DISTINCT oi.order_id) AS orders,
        COUNT(*) AS items_sold,
        ROUND(SUM(oi.price), 2) AS revenue,
        ROUND(SUM(oi.freight_value), 2) AS freight
    FROM order_items oi
    JOIN sellers s
        ON oi.seller_id = s.seller_id
    GROUP BY
        oi.seller_id,
        s.seller_city,
        s.seller_state
    ORDER BY revenue DESC
)
WHERE ROWNUM <= 10;


-- ============================================================
-- 7. SELLER PERFORMANCE
-- ============================================================

PROMPT
PROMPT 7. SELLER PERFORMANCE
PROMPT ------------------------------------------------------------

SELECT
    oi.seller_id,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    COUNT(*) AS total_items,
    ROUND(SUM(oi.price), 2) AS revenue,
    ROUND(AVG(oi.price), 2) AS average_item_price,
    ROUND(AVG(oi.freight_value), 2) AS average_freight
FROM order_items oi
GROUP BY oi.seller_id
ORDER BY revenue DESC;


-- ============================================================
-- 8. AVERAGE PRODUCT PRICE BY CATEGORY
-- ============================================================

PROMPT
PROMPT 8. AVERAGE PRODUCT PRICE BY CATEGORY
PROMPT ------------------------------------------------------------

SELECT
    NVL(
        pct.product_category_name_english,
        p.product_category_name
    ) AS category,
    COUNT(DISTINCT p.product_id) AS products,
    ROUND(AVG(oi.price), 2) AS average_price,
    ROUND(MIN(oi.price), 2) AS minimum_price,
    ROUND(MAX(oi.price), 2) AS maximum_price
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_translation pct
    ON p.product_category_name =
       pct.product_category_name
GROUP BY
    NVL(
        pct.product_category_name_english,
        p.product_category_name
    )
ORDER BY average_price DESC;


-- ============================================================
-- 9. FREIGHT ANALYSIS BY STATE
-- ============================================================

PROMPT
PROMPT 9. FREIGHT ANALYSIS BY STATE
PROMPT ------------------------------------------------------------

SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.freight_value), 2) AS total_freight,
    ROUND(AVG(oi.freight_value), 2) AS average_freight,
    ROUND(AVG(oi.price), 2) AS average_item_price
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY total_freight DESC;


-- ============================================================
-- 10. REVENUE BY CUSTOMER STATE
-- ============================================================

PROMPT
PROMPT 10. REVENUE BY CUSTOMER STATE
PROMPT ------------------------------------------------------------

SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT o.customer_id) AS customers,
    ROUND(SUM(oi.price), 2) AS revenue,
    ROUND(SUM(oi.freight_value), 2) AS freight
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY revenue DESC;


-- ============================================================
-- 11. ORDER VALUE DISTRIBUTION
-- ============================================================

PROMPT
PROMPT 11. ORDER VALUE DISTRIBUTION
PROMPT ------------------------------------------------------------

SELECT
    CASE
        WHEN order_value < 50 THEN 'Under 50'
        WHEN order_value < 100 THEN '50 - 99'
        WHEN order_value < 250 THEN '100 - 249'
        WHEN order_value < 500 THEN '250 - 499'
        ELSE '500+'
    END AS order_value_range,
    COUNT(*) AS order_count
FROM (
    SELECT
        order_id,
        SUM(price) AS order_value
    FROM order_items
    GROUP BY order_id
)
GROUP BY
    CASE
        WHEN order_value < 50 THEN 'Under 50'
        WHEN order_value < 100 THEN '50 - 99'
        WHEN order_value < 250 THEN '100 - 249'
        WHEN order_value < 500 THEN '250 - 499'
        ELSE '500+'
    END
ORDER BY order_count DESC;


-- ============================================================
-- 12. TOP 10 ORDERS BY ORDER VALUE
-- ============================================================

PROMPT
PROMPT 12. TOP 10 ORDERS BY ORDER VALUE
PROMPT ------------------------------------------------------------

SELECT *
FROM (
    SELECT
        order_id,
        ROUND(SUM(price), 2) AS order_value,
        ROUND(SUM(freight_value), 2) AS freight_value,
        ROUND(
            SUM(price + freight_value),
            2
        ) AS total_order_value
    FROM order_items
    GROUP BY order_id
    ORDER BY total_order_value DESC
)
WHERE ROWNUM <= 10;


-- ============================================================
-- 13. PAYMENT TYPE SALES
-- ============================================================

PROMPT
PROMPT 13. PAYMENT TYPE SALES
PROMPT ------------------------------------------------------------

SELECT
    payment_type,
    COUNT(DISTINCT order_id) AS orders,
    ROUND(SUM(payment_value), 2) AS payment_value,
    ROUND(AVG(payment_value), 2) AS average_payment
FROM order_payments
GROUP BY payment_type
ORDER BY payment_value DESC;


-- ============================================================
-- 14. PAYMENT INSTALLMENT ANALYSIS
-- ============================================================

PROMPT
PROMPT 14. PAYMENT INSTALLMENT ANALYSIS
PROMPT ------------------------------------------------------------

SELECT
    payment_installments,
    COUNT(*) AS payment_count,
    ROUND(SUM(payment_value), 2) AS payment_value,
    ROUND(AVG(payment_value), 2) AS average_payment
FROM order_payments
GROUP BY payment_installments
ORDER BY payment_installments;


-- ============================================================
-- 15. REVENUE BY ORDER STATUS
-- ============================================================

PROMPT
PROMPT 15. REVENUE BY ORDER STATUS
PROMPT ------------------------------------------------------------

SELECT
    o.order_status,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(SUM(oi.price), 2) AS revenue,
    ROUND(SUM(oi.freight_value), 2) AS freight
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY o.order_status
ORDER BY revenue DESC;


-- ============================================================
-- 16. PRODUCT CATEGORY PERFORMANCE
-- ============================================================

PROMPT
PROMPT 16. PRODUCT CATEGORY PERFORMANCE
PROMPT ------------------------------------------------------------

SELECT
    NVL(
        pct.product_category_name_english,
        p.product_category_name
    ) AS category,
    COUNT(DISTINCT p.product_id) AS products,
    COUNT(DISTINCT oi.order_id) AS orders,
    COUNT(*) AS items_sold,
    ROUND(SUM(oi.price), 2) AS revenue,
    ROUND(AVG(oi.price), 2) AS average_price
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
LEFT JOIN product_category_translation pct
    ON p.product_category_name =
       pct.product_category_name
GROUP BY
    NVL(
        pct.product_category_name_english,
        p.product_category_name
    )
ORDER BY revenue DESC;


-- ============================================================
-- 17. REVENUE CONCENTRATION — TOP SELLERS
-- ============================================================

PROMPT
PROMPT 17. REVENUE CONCENTRATION - TOP SELLERS
PROMPT ------------------------------------------------------------

SELECT
    ROUND(
        SUM(
            CASE
                WHEN seller_rank <= 10 THEN revenue
                ELSE 0
            END
        ),
        2
    ) AS top_10_seller_revenue,
    ROUND(SUM(revenue), 2) AS total_seller_revenue,
    ROUND(
        SUM(
            CASE
                WHEN seller_rank <= 10 THEN revenue
                ELSE 0
            END
        ) * 100 / SUM(revenue),
        2
    ) AS top_10_revenue_percentage
FROM (
    SELECT
        seller_id,
        SUM(price) AS revenue,
        RANK() OVER (
            ORDER BY SUM(price) DESC
        ) AS seller_rank
    FROM order_items
    GROUP BY seller_id
);


-- ============================================================
-- 18. REVENUE CONCENTRATION — TOP PRODUCTS
-- ============================================================

PROMPT
PROMPT 18. REVENUE CONCENTRATION - TOP PRODUCTS
PROMPT ------------------------------------------------------------

SELECT
    ROUND(
        SUM(
            CASE
                WHEN product_rank <= 10 THEN revenue
                ELSE 0
            END
        ),
        2
    ) AS top_10_product_revenue,
    ROUND(SUM(revenue), 2) AS total_product_revenue,
    ROUND(
        SUM(
            CASE
                WHEN product_rank <= 10 THEN revenue
                ELSE 0
            END
        ) * 100 / SUM(revenue),
        2
    ) AS top_10_revenue_percentage
FROM (
    SELECT
        product_id,
        SUM(price) AS revenue,
        RANK() OVER (
            ORDER BY SUM(price) DESC
        ) AS product_rank
    FROM order_items
    GROUP BY product_id
);


-- ============================================================
-- 19. MONTHLY ORDER GROWTH
-- ============================================================

PROMPT
PROMPT 19. MONTHLY ORDER GROWTH
PROMPT ------------------------------------------------------------

SELECT
    order_month,
    total_orders,
    LAG(total_orders) OVER (
        ORDER BY order_month
    ) AS previous_month_orders,
    total_orders -
        LAG(total_orders) OVER (
            ORDER BY order_month
        ) AS order_change
FROM (
    SELECT
        TO_CHAR(
            order_purchase_timestamp,
            'YYYY-MM'
        ) AS order_month,
        COUNT(*) AS total_orders
    FROM orders
    GROUP BY TO_CHAR(
        order_purchase_timestamp,
        'YYYY-MM'
    )
)
ORDER BY order_month;


-- ============================================================
-- 20. MONTHLY REVENUE GROWTH
-- ============================================================

PROMPT
PROMPT 20. MONTHLY REVENUE GROWTH
PROMPT ------------------------------------------------------------

SELECT
    order_month,
    revenue,
    previous_month_revenue,
    ROUND(
        (revenue - previous_month_revenue)
        / NULLIF(previous_month_revenue, 0) * 100,
        2
    ) AS revenue_growth_percentage
FROM (
    SELECT
        order_month,
        revenue,
        LAG(revenue) OVER (
            ORDER BY order_month
        ) AS previous_month_revenue
    FROM (
        SELECT
            TO_CHAR(
                o.order_purchase_timestamp,
                'YYYY-MM'
            ) AS order_month,
            SUM(oi.price) AS revenue
        FROM orders o
        JOIN order_items oi
            ON o.order_id = oi.order_id
        GROUP BY TO_CHAR(
            o.order_purchase_timestamp,
            'YYYY-MM'
        )
    )
)
ORDER BY order_month;


-- ============================================================
-- 21. DAY OF WEEK ORDER SEASONALITY
-- ============================================================

PROMPT
PROMPT 21. DAY OF WEEK ORDER SEASONALITY
PROMPT ------------------------------------------------------------

SELECT
    TO_CHAR(order_purchase_timestamp, 'Day') AS day_of_week,
    TO_CHAR(order_purchase_timestamp, 'D') AS day_number,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(COUNT(DISTINCT order_id) * 100.0 / (SELECT COUNT(*) FROM orders), 2) AS order_percentage
FROM orders
WHERE order_purchase_timestamp IS NOT NULL
GROUP BY
    TO_CHAR(order_purchase_timestamp, 'Day'),
    TO_CHAR(order_purchase_timestamp, 'D')
ORDER BY day_number;


-- ============================================================
-- 22. HOURLY ORDER VOLUMES (PEAK TRANSACTION WINDOWS)
-- ============================================================

PROMPT
PROMPT 22. HOURLY ORDER VOLUMES
PROMPT ------------------------------------------------------------

SELECT
    TO_CHAR(order_purchase_timestamp, 'HH24') AS purchase_hour,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(COUNT(DISTINCT order_id) * 100.0 / (SELECT COUNT(*) FROM orders), 2) AS order_percentage
FROM orders
WHERE order_purchase_timestamp IS NOT NULL
GROUP BY TO_CHAR(order_purchase_timestamp, 'HH24')
ORDER BY purchase_hour;


-- ============================================================
-- SALES ANALYSIS COMPLETE
-- ============================================================

PROMPT
PROMPT ============================================================
PROMPT SALES ANALYSIS COMPLETED
PROMPT ============================================================