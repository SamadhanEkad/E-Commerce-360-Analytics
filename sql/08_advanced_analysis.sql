-- ============================================================
-- E-COMMERCE 360° ANALYTICS
-- File: 08_advanced_analysis.sql
-- Purpose: Advanced Business Analytics (DENSE_RANK, Pareto, Logistics SLA, CSAT)
-- Database: Oracle Database 21c XE / ANSI SQL Compatible
-- ============================================================

SET ECHO ON
SET FEEDBACK ON
SET VERIFY OFF
SET DEFINE OFF
SET HEADING ON
SET LINESIZE 200
SET PAGESIZE 100
SET SQLBLANKLINES ON

PROMPT ============================================================
PROMPT E-COMMERCE 360° - ADVANCED BUSINESS ANALYSIS
PROMPT ============================================================


-- ============================================================
-- 1. TOP SELLERS BY REVENUE
-- ============================================================

PROMPT
PROMPT 1. TOP SELLERS BY REVENUE
PROMPT ------------------------------------------------------------

SELECT
    seller_id,
    ROUND(SUM(price), 2) AS total_revenue,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(*) AS total_items
FROM order_items
GROUP BY seller_id
ORDER BY total_revenue DESC
FETCH FIRST 10 ROWS ONLY;


-- ============================================================
-- 2. TOP PRODUCT CATEGORIES BY REVENUE
-- ============================================================

PROMPT
PROMPT 2. TOP PRODUCT CATEGORIES BY REVENUE
PROMPT ------------------------------------------------------------

SELECT
    NVL(
        pct.product_category_name_english,
        p.product_category_name
    ) AS category_name,
    ROUND(SUM(oi.price), 2) AS total_revenue,
    COUNT(*) AS items_sold
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_translation pct
    ON p.product_category_name = pct.product_category_name
GROUP BY
    NVL(
        pct.product_category_name_english,
        p.product_category_name
    )
ORDER BY total_revenue DESC
FETCH FIRST 10 ROWS ONLY;


-- ============================================================
-- 3. TOP N (TOP 3) PRODUCTS PER CATEGORY (USING DENSE_RANK)
-- ============================================================

PROMPT
PROMPT 3. TOP 3 PRODUCTS PER CATEGORY (DENSE_RANK)
PROMPT ------------------------------------------------------------

WITH product_category_sales AS (
    SELECT
        NVL(pct.product_category_name_english, p.product_category_name) AS category_name,
        oi.product_id,
        COUNT(*) AS units_sold,
        ROUND(SUM(oi.price), 2) AS product_revenue,
        DENSE_RANK() OVER (
            PARTITION BY NVL(pct.product_category_name_english, p.product_category_name)
            ORDER BY SUM(oi.price) DESC
        ) AS rank_in_category
    FROM order_items oi
    JOIN products p
        ON oi.product_id = p.product_id
    LEFT JOIN product_category_translation pct
        ON p.product_category_name = pct.product_category_name
    WHERE p.product_category_name IS NOT NULL
    GROUP BY
        NVL(pct.product_category_name_english, p.product_category_name),
        oi.product_id
)
SELECT *
FROM (
    SELECT
        category_name,
        rank_in_category,
        product_id,
        units_sold,
        product_revenue
    FROM product_category_sales
    WHERE rank_in_category <= 3
    ORDER BY category_name, rank_in_category
)
FETCH FIRST 30 ROWS ONLY;


-- ============================================================
-- 4. PARETO SELLER REVENUE CONCENTRATION CURVE (80/20 RULE)
-- ============================================================

PROMPT
PROMPT 4. PARETO SELLER ANALYSIS (TOP SELLERS CUMULATIVE REVENUE)
PROMPT ------------------------------------------------------------

WITH seller_revenues AS (
    SELECT
        seller_id,
        ROUND(SUM(price), 2) AS revenue
    FROM order_items
    GROUP BY seller_id
),
seller_pareto AS (
    SELECT
        seller_id,
        revenue,
        ROW_NUMBER() OVER (ORDER BY revenue DESC) AS seller_rank,
        COUNT(*) OVER () AS total_sellers,
        ROUND(SUM(revenue) OVER (ORDER BY revenue DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 2) AS cumulative_revenue,
        ROUND(SUM(revenue) OVER (), 2) AS total_revenue
    FROM seller_revenues
)
SELECT
    seller_rank,
    seller_id,
    revenue,
    cumulative_revenue,
    ROUND(seller_rank * 100.0 / total_sellers, 2) AS pct_of_all_sellers,
    ROUND(cumulative_revenue * 100.0 / total_revenue, 2) AS cumulative_revenue_pct,
    CASE
        WHEN cumulative_revenue <= total_revenue * 0.80 THEN 'Top 80% Revenue Contributor'
        ELSE 'Tail 20% Revenue Contributor'
    END AS pareto_classification
FROM seller_pareto
FETCH FIRST 20 ROWS ONLY;


-- ============================================================
-- 5. PARETO SELLER SUMMARY SCORECARD
-- ============================================================

PROMPT
PROMPT 5. PARETO 80/20 SUMMARY: SELLERS DRIVING 80% REVENUE
PROMPT ------------------------------------------------------------

WITH seller_revenues AS (
    SELECT
        seller_id,
        SUM(price) AS revenue
    FROM order_items
    GROUP BY seller_id
),
seller_ranked AS (
    SELECT
        seller_id,
        revenue,
        ROW_NUMBER() OVER (ORDER BY revenue DESC) AS seller_rank,
        COUNT(*) OVER () AS total_sellers,
        SUM(revenue) OVER (ORDER BY revenue DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_rev,
        SUM(revenue) OVER () AS total_rev
    FROM seller_revenues
)
SELECT
    total_sellers,
    COUNT(CASE WHEN cumulative_rev <= total_rev * 0.80 THEN 1 END) AS sellers_generating_80_pct_rev,
    ROUND(
        COUNT(CASE WHEN cumulative_rev <= total_rev * 0.80 THEN 1 END) * 100.0 / total_sellers,
        2
    ) AS pct_sellers_generating_80pct_rev
FROM seller_ranked
GROUP BY total_sellers;


-- ============================================================
-- 6. PAYMENT TYPE ANALYSIS
-- ============================================================

PROMPT
PROMPT 6. PAYMENT TYPE ANALYSIS
PROMPT ------------------------------------------------------------

SELECT
    payment_type,
    COUNT(DISTINCT order_id) AS order_count,
    ROUND(SUM(payment_value), 2) AS total_payment_value,
    ROUND(AVG(payment_value), 2) AS average_payment_value
FROM order_payments
GROUP BY payment_type
ORDER BY total_payment_value DESC;


-- ============================================================
-- 7. PAYMENT INSTALLMENT ANALYSIS
-- ============================================================

PROMPT
PROMPT 7. PAYMENT INSTALLMENT ANALYSIS
PROMPT ------------------------------------------------------------

SELECT
    payment_installments,
    COUNT(DISTINCT order_id) AS order_count,
    ROUND(SUM(payment_value), 2) AS total_payment_value,
    ROUND(AVG(payment_value), 2) AS average_payment_value
FROM order_payments
GROUP BY payment_installments
ORDER BY payment_installments;


-- ============================================================
-- 8. ORDER FULFILLMENT STATUS
-- ============================================================

PROMPT
PROMPT 8. ORDER STATUS DISTRIBUTION
PROMPT ------------------------------------------------------------

SELECT
    order_status,
    COUNT(*) AS order_count,
    ROUND(
        COUNT(*) * 100.0 /
        NULLIF((SELECT COUNT(*) FROM orders), 0),
        2
    ) AS percentage_of_orders
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;


-- ============================================================
-- 9. DELIVERY CYCLE PERFORMANCE
-- ============================================================

PROMPT
PROMPT 9. DELIVERY CYCLE DAYS
PROMPT ------------------------------------------------------------

SELECT
    ROUND(
        AVG(
            CAST(order_delivered_customer_date AS DATE)
            - CAST(order_purchase_timestamp AS DATE)
        ),
        2
    ) AS avg_delivery_days,
    ROUND(
        AVG(
            CAST(order_estimated_delivery_date AS DATE)
            - CAST(order_purchase_timestamp AS DATE)
        ),
        2
    ) AS avg_estimated_delivery_days,
    ROUND(
        AVG(
            CAST(order_delivered_carrier_date AS DATE)
            - CAST(order_purchase_timestamp AS DATE)
        ),
        2
    ) AS avg_carrier_lead_days
FROM orders
WHERE order_delivered_customer_date IS NOT NULL
  AND order_purchase_timestamp IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL;


-- ============================================================
-- 10. ON-TIME VS LATE DELIVERY SLA
-- ============================================================

PROMPT
PROMPT 10. EARLY VS LATE DELIVERY
PROMPT ------------------------------------------------------------

SELECT
    CASE
        WHEN order_delivered_customer_date <= order_estimated_delivery_date
            THEN 'ON TIME / EARLY'
        WHEN order_delivered_customer_date > order_estimated_delivery_date
            THEN 'LATE'
        ELSE 'NOT DELIVERED'
    END AS delivery_performance,
    COUNT(*) AS order_count,
    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders WHERE order_status = 'delivered'),
        2
    ) AS pct_of_delivered_orders
FROM orders
WHERE order_status = 'delivered'
GROUP BY
    CASE
        WHEN order_delivered_customer_date <= order_estimated_delivery_date
            THEN 'ON TIME / EARLY'
        WHEN order_delivered_customer_date > order_estimated_delivery_date
            THEN 'LATE'
        ELSE 'NOT DELIVERED'
    END
ORDER BY order_count DESC;


-- ============================================================
-- 11. LOGISTICS SLA IMPACT ON CUSTOMER REVIEW SCORE (CSAT GAP)
-- ============================================================

PROMPT
PROMPT 11. REVIEW SCORE VS DELIVERY PERFORMANCE (CSAT IMPACT)
PROMPT ------------------------------------------------------------

SELECT
    CASE
        WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date
            THEN 'ON TIME / EARLY'
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
            THEN 'LATE'
        ELSE 'NOT DELIVERED'
    END AS delivery_performance,
    ROUND(AVG(r.review_score), 2) AS average_review_score,
    COUNT(r.review_id) AS review_count,
    ROUND(
        COUNT(CASE WHEN r.review_score >= 4 THEN 1 END) * 100.0 / COUNT(*),
        2
    ) AS satisfied_review_pct,
    ROUND(
        COUNT(CASE WHEN r.review_score <= 2 THEN 1 END) * 100.0 / COUNT(*),
        2
    ) AS negative_review_pct
FROM orders o
JOIN order_reviews r
    ON o.order_id = r.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY
    CASE
        WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date
            THEN 'ON TIME / EARLY'
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
            THEN 'LATE'
        ELSE 'NOT DELIVERED'
    END
ORDER BY average_review_score DESC;


-- ============================================================
-- 12. INTER-STATE VS INTRA-STATE LOGISTICS
-- ============================================================

PROMPT
PROMPT 12. INTER-STATE VS INTRA-STATE FULFILLMENT ROUTE
PROMPT ------------------------------------------------------------

SELECT
    CASE
        WHEN s.seller_state = c.customer_state THEN 'Intra-State (Same State)'
        ELSE 'Inter-State (Different State)'
    END AS shipping_route,
    COUNT(DISTINCT oi.order_id) AS order_count,
    ROUND(
        COUNT(DISTINCT oi.order_id) * 100.0 / (SELECT COUNT(DISTINCT order_id) FROM order_items),
        2
    ) AS order_percentage,
    ROUND(AVG(oi.freight_value), 2) AS average_freight,
    ROUND(AVG(CAST(o.order_delivered_customer_date AS DATE) - CAST(o.order_purchase_timestamp AS DATE)), 1) AS avg_delivery_days
FROM order_items oi
JOIN sellers s
    ON oi.seller_id = s.seller_id
JOIN orders o
    ON oi.order_id = o.order_id
JOIN customers c
    ON o.customer_id = c.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY
    CASE
        WHEN s.seller_state = c.customer_state THEN 'Intra-State (Same State)'
        ELSE 'Inter-State (Different State)'
    END
ORDER BY order_count DESC;


-- ============================================================
-- 13. FREIGHT COST RATIO TO PRODUCT REVENUE
-- ============================================================

PROMPT
PROMPT 13. FREIGHT COST ANALYSIS
PROMPT ------------------------------------------------------------

SELECT
    ROUND(SUM(freight_value), 2) AS total_freight_cost,
    ROUND(AVG(freight_value), 2) AS average_freight_cost,
    ROUND(SUM(price), 2) AS total_product_revenue,
    ROUND(
        SUM(freight_value) * 100.0 /
        NULLIF(SUM(price), 0),
        2
    ) AS freight_to_revenue_percentage
FROM order_items;


-- ============================================================
-- 14. TOP HIGH FREIGHT OUTLAY ORDERS
-- ============================================================

PROMPT
PROMPT 14. TOP ORDERS BY FREIGHT COST
PROMPT ------------------------------------------------------------

SELECT *
FROM (
    SELECT
        order_id,
        ROUND(SUM(price), 2) AS order_value,
        ROUND(SUM(freight_value), 2) AS freight_cost,
        ROUND(
            SUM(freight_value) * 100.0 /
            NULLIF(SUM(price), 0),
            2
        ) AS freight_percentage
    FROM order_items
    GROUP BY order_id
    ORDER BY freight_cost DESC
)
FETCH FIRST 10 ROWS ONLY;


-- ============================================================
-- 15. AVERAGE ORDER VALUE BY PAYMENT TYPE
-- ============================================================

PROMPT
PROMPT 15. AVERAGE ORDER VALUE BY PAYMENT TYPE
PROMPT ------------------------------------------------------------

SELECT
    payment_type,
    ROUND(AVG(payment_value), 2) AS average_order_value,
    ROUND(MAX(payment_value), 2) AS maximum_order_value,
    ROUND(MIN(payment_value), 2) AS minimum_order_value
FROM order_payments
GROUP BY payment_type
ORDER BY average_order_value DESC;


-- ============================================================
-- 16. MULTI-ITEM ORDER BASKET ANALYSIS
-- ============================================================

PROMPT
PROMPT 16. MULTI-ITEM ORDER BASKET ANALYSIS
PROMPT ------------------------------------------------------------

SELECT
    CASE
        WHEN item_count = 1 THEN '1 Item (Single)'
        WHEN item_count BETWEEN 2 AND 3 THEN '2-3 Items'
        ELSE '4+ Items'
    END AS basket_size_group,
    COUNT(*) AS order_count,
    ROUND(AVG(order_value), 2) AS average_order_value,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(DISTINCT order_id) FROM order_items), 2) AS pct_of_orders
FROM (
    SELECT
        order_id,
        COUNT(*) AS item_count,
        SUM(price) AS order_value
    FROM order_items
    GROUP BY order_id
)
GROUP BY
    CASE
        WHEN item_count = 1 THEN '1 Item (Single)'
        WHEN item_count BETWEEN 2 AND 3 THEN '2-3 Items'
        ELSE '4+ Items'
    END
ORDER BY order_count DESC;


-- ============================================================
-- 17. CATEGORIES WITH HIGHEST & LOWEST CSAT
-- ============================================================

PROMPT
PROMPT 17. CATEGORIES WITH HIGHEST CSAT (MIN 100 REVIEWS)
PROMPT ------------------------------------------------------------

SELECT *
FROM (
    SELECT
        NVL(pct.product_category_name_english, p.product_category_name) AS category_name,
        COUNT(r.review_id) AS total_reviews,
        ROUND(AVG(r.review_score), 2) AS average_csat
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    LEFT JOIN product_category_translation pct ON p.product_category_name = pct.product_category_name
    JOIN order_reviews r ON oi.order_id = r.order_id
    WHERE p.product_category_name IS NOT NULL
    GROUP BY NVL(pct.product_category_name_english, p.product_category_name)
    HAVING COUNT(r.review_id) >= 100
    ORDER BY average_csat DESC
)
FETCH FIRST 10 ROWS ONLY;


-- ============================================================
-- 18. SELLER CONCENTRATION & REVENUE SHARE
-- ============================================================

PROMPT
PROMPT 18. TOP 10 SELLERS REVENUE SHARE
PROMPT ------------------------------------------------------------

SELECT
    ROUND(
        SUM(CASE WHEN seller_rank <= 10 THEN revenue ELSE 0 END),
        2
    ) AS top_10_seller_revenue,
    ROUND(SUM(revenue), 2) AS total_marketplace_revenue,
    ROUND(
        SUM(CASE WHEN seller_rank <= 10 THEN revenue ELSE 0 END) * 100.0 / SUM(revenue),
        2
    ) AS top_10_revenue_share_pct
FROM (
    SELECT
        seller_id,
        SUM(price) AS revenue,
        RANK() OVER (ORDER BY SUM(price) DESC) AS seller_rank
    FROM order_items
    GROUP BY seller_id
);


-- ============================================================
-- ADVANCED BUSINESS ANALYSIS COMPLETE
-- ============================================================

PROMPT
PROMPT ============================================================
PROMPT ADVANCED BUSINESS ANALYSIS COMPLETED SUCCESSFULLY
PROMPT ============================================================
