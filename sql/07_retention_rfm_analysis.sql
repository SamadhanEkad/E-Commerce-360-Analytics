-- ============================================================
-- E-Commerce 360° Analytics
-- File: 07_retention_rfm_analysis.sql
-- Purpose: Customer Retention, Cohort Matrix and RFM Segmentation
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
PROMPT E-COMMERCE 360° - RETENTION AND RFM ANALYSIS
PROMPT ============================================================


-- ============================================================
-- 1. CUSTOMER ORDER FREQUENCY (UNIQUE BUYERS)
-- ============================================================

PROMPT
PROMPT 1. CUSTOMER ORDER FREQUENCY
PROMPT ------------------------------------------------------------

SELECT
    order_count,
    COUNT(*) AS customer_count,
    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(DISTINCT customer_unique_id) FROM customers),
        2
    ) AS percentage_of_customers
FROM
(
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
)
GROUP BY order_count
ORDER BY order_count;


-- ============================================================
-- 2. ONE-TIME VS REPEAT CUSTOMERS
-- ============================================================

PROMPT
PROMPT 2. ONE-TIME VS REPEAT CUSTOMERS
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
FROM
(
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
    END
ORDER BY customer_count DESC;


-- ============================================================
-- 3. REPEAT CUSTOMER RATE
-- ============================================================

PROMPT
PROMPT 3. REPEAT CUSTOMER RATE
PROMPT ------------------------------------------------------------

SELECT
    ROUND(
        100.0 * SUM(
            CASE
                WHEN order_count > 1 THEN 1
                ELSE 0
            END
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS repeat_customer_rate_percentage
FROM
(
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
);


-- ============================================================
-- 4. CUSTOMER FIRST AND LAST PURCHASE (TOP REPEAT BUYERS)
-- ============================================================

PROMPT
PROMPT 4. CUSTOMER FIRST AND LAST PURCHASE (TOP REPEAT BUYERS)
PROMPT ------------------------------------------------------------

SELECT *
FROM
(
    SELECT
        c.customer_unique_id,
        MIN(o.order_purchase_timestamp) AS first_purchase,
        MAX(o.order_purchase_timestamp) AS last_purchase,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
    HAVING COUNT(DISTINCT o.order_id) > 1
    ORDER BY total_orders DESC, last_purchase DESC
)
FETCH FIRST 20 ROWS ONLY;


-- ============================================================
-- 5. CUSTOMER LIFESPAN (DAYS BETWEEN FIRST & LAST ORDER)
-- ============================================================

PROMPT
PROMPT 5. CUSTOMER LIFESPAN (DAYS FOR REPEAT BUYERS)
PROMPT ------------------------------------------------------------

SELECT *
FROM
(
    SELECT
        c.customer_unique_id,
        MIN(o.order_purchase_timestamp) AS first_purchase,
        MAX(o.order_purchase_timestamp) AS last_purchase,
        COUNT(DISTINCT o.order_id) AS total_orders,
        ROUND(
            CAST(MAX(o.order_purchase_timestamp) AS DATE)
            - CAST(MIN(o.order_purchase_timestamp) AS DATE)
        ) AS lifespan_days
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
    HAVING COUNT(DISTINCT o.order_id) > 1
    ORDER BY lifespan_days DESC
)
FETCH FIRST 20 ROWS ONLY;


-- ============================================================
-- 6. CUSTOMER RECENCY (DAYS SINCE LAST PURCHASE)
-- ============================================================

PROMPT
PROMPT 6. CUSTOMER RECENCY (DAYS SINCE LAST PURCHASE)
PROMPT ------------------------------------------------------------

SELECT *
FROM
(
    SELECT
        c.customer_unique_id,
        MAX(o.order_purchase_timestamp) AS last_purchase,
        ROUND(
            CAST(
                (SELECT MAX(order_purchase_timestamp) FROM orders)
                AS DATE
            )
            - CAST(MAX(o.order_purchase_timestamp) AS DATE)
        ) AS days_since_last_purchase
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
    ORDER BY days_since_last_purchase ASC
)
FETCH FIRST 20 ROWS ONLY;


-- ============================================================
-- 7. RECENCY SEGMENTS
-- ============================================================

PROMPT
PROMPT 7. RECENCY SEGMENTS
PROMPT ------------------------------------------------------------

SELECT
    recency_segment,
    COUNT(*) AS customer_count,
    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(DISTINCT customer_unique_id) FROM customers),
        2
    ) AS percentage
FROM
(
    SELECT
        c.customer_unique_id,
        days_since_last_purchase,
        CASE
            WHEN days_since_last_purchase <= 30
                THEN 'Active (0-30 Days)'
            WHEN days_since_last_purchase <= 90
                THEN 'Recent (31-90 Days)'
            WHEN days_since_last_purchase <= 180
                THEN 'At Risk (91-180 Days)'
            WHEN days_since_last_purchase <= 365
                THEN 'Dormant (181-365 Days)'
            ELSE 'Inactive (365+ Days)'
        END AS recency_segment
    FROM
    (
        SELECT
            c.customer_unique_id,
            ROUND(
                CAST(
                    (SELECT MAX(order_purchase_timestamp) FROM orders)
                    AS DATE
                )
                - CAST(MAX(o.order_purchase_timestamp) AS DATE)
            ) AS days_since_last_purchase
        FROM orders o
        JOIN customers c
            ON o.customer_id = c.customer_id
        GROUP BY c.customer_unique_id
    )
)
GROUP BY recency_segment
ORDER BY customer_count DESC;


-- ============================================================
-- 8. PURCHASE FREQUENCY SEGMENTS
-- ============================================================

PROMPT
PROMPT 8. PURCHASE FREQUENCY SEGMENTS
PROMPT ------------------------------------------------------------

SELECT
    frequency_segment,
    COUNT(*) AS customer_count,
    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(DISTINCT customer_unique_id) FROM customers),
        2
    ) AS percentage
FROM
(
    SELECT
        c.customer_unique_id,
        order_count,
        CASE
            WHEN order_count = 1 THEN '1 Order (One-Time)'
            WHEN order_count = 2 THEN '2 Orders (Occasional)'
            WHEN order_count BETWEEN 3 AND 5 THEN '3-5 Orders (Frequent)'
            ELSE '6+ Orders (Power Buyers)'
        END AS frequency_segment
    FROM
    (
        SELECT
            c.customer_unique_id,
            COUNT(DISTINCT o.order_id) AS order_count
        FROM orders o
        JOIN customers c
            ON o.customer_id = c.customer_id
        GROUP BY c.customer_unique_id
    )
)
GROUP BY frequency_segment
ORDER BY customer_count DESC;


-- ============================================================
-- 9. CUSTOMER MONETARY VALUE (TOP SPENDERS)
-- ============================================================

PROMPT
PROMPT 9. TOP 20 CUSTOMERS BY MONETARY VALUE
PROMPT ------------------------------------------------------------

SELECT *
FROM
(
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders,
        ROUND(SUM(oi.price), 2) AS monetary_value
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_unique_id
    ORDER BY monetary_value DESC
)
FETCH FIRST 20 ROWS ONLY;


-- ============================================================
-- 10. MONETARY VALUE SEGMENTS
-- ============================================================

PROMPT
PROMPT 10. MONETARY VALUE SEGMENTS
PROMPT ------------------------------------------------------------

SELECT
    monetary_segment,
    COUNT(*) AS customer_count,
    ROUND(AVG(monetary_value), 2) AS average_spend,
    ROUND(SUM(monetary_value), 2) AS total_spend
FROM
(
    SELECT
        c.customer_unique_id,
        monetary_value,
        CASE
            WHEN monetary_value < 50 THEN 'Low Value (< 50)'
            WHEN monetary_value < 150 THEN 'Medium-Low (50-149)'
            WHEN monetary_value < 500 THEN 'Medium-High (150-499)'
            WHEN monetary_value < 1000 THEN 'High Value (500-999)'
            ELSE 'Very High Value (1000+)'
        END AS monetary_segment
    FROM
    (
        SELECT
            c.customer_unique_id,
            SUM(oi.price) AS monetary_value
        FROM orders o
        JOIN customers c
            ON o.customer_id = c.customer_id
        JOIN order_items oi
            ON o.order_id = oi.order_id
        GROUP BY c.customer_unique_id
    )
)
GROUP BY monetary_segment
ORDER BY total_spend DESC;


-- ============================================================
-- 11. RFM SCORES (NTILE 5-TIER SCORING)
-- ============================================================

PROMPT
PROMPT 11. SAMPLE RFM SCORES
PROMPT ------------------------------------------------------------

WITH customer_rfm AS
(
    SELECT
        c.customer_unique_id,
        ROUND(
            CAST(
                (SELECT MAX(order_purchase_timestamp) FROM orders)
                AS DATE
            )
            - CAST(MAX(o.order_purchase_timestamp) AS DATE)
        ) AS recency,
        COUNT(DISTINCT o.order_id) AS frequency,
        ROUND(SUM(oi.price), 2) AS monetary
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_unique_id
),
rfm_scores AS
(
    SELECT
        customer_unique_id,
        recency,
        frequency,
        monetary,
        NTILE(5) OVER (ORDER BY recency DESC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency ASC) AS f_score,
        NTILE(5) OVER (ORDER BY monetary ASC) AS m_score
    FROM customer_rfm
)
SELECT
    customer_unique_id,
    recency AS recency_days,
    frequency AS order_count,
    monetary AS total_spent,
    r_score,
    f_score,
    m_score,
    r_score || f_score || m_score AS rfm_combined_score
FROM rfm_scores
ORDER BY monetary DESC
FETCH FIRST 20 ROWS ONLY;


-- ============================================================
-- 12. RFM CUSTOMER SEGMENTATION SUMMARY
-- ============================================================

PROMPT
PROMPT 12. RFM CUSTOMER SEGMENTATION
PROMPT ------------------------------------------------------------

WITH customer_rfm AS
(
    SELECT
        c.customer_unique_id,
        ROUND(
            CAST(
                (SELECT MAX(order_purchase_timestamp) FROM orders)
                AS DATE
            )
            - CAST(MAX(o.order_purchase_timestamp) AS DATE)
        ) AS recency,
        COUNT(DISTINCT o.order_id) AS frequency,
        SUM(oi.price) AS monetary
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_unique_id
),
rfm_scores AS
(
    SELECT
        customer_unique_id,
        recency,
        frequency,
        monetary,
        NTILE(5) OVER (ORDER BY recency DESC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency ASC) AS f_score,
        NTILE(5) OVER (ORDER BY monetary ASC) AS m_score
    FROM customer_rfm
),
rfm_segments AS
(
    SELECT
        customer_unique_id,
        recency,
        frequency,
        monetary,
        CASE
            WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4
                THEN 'Champions'
            WHEN r_score >= 3 AND f_score >= 3 AND m_score >= 3
                THEN 'Loyal Customers'
            WHEN r_score >= 4 AND f_score <= 2
                THEN 'New / Promising'
            WHEN r_score <= 2 AND m_score >= 4
                THEN 'High-Value At Risk'
            WHEN r_score <= 2 AND f_score <= 2
                THEN 'Lost / Inactive'
            ELSE 'Potential Loyalists'
        END AS rfm_segment
    FROM rfm_scores
)
SELECT
    rfm_segment,
    COUNT(*) AS customer_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM rfm_segments), 2) AS percentage,
    ROUND(AVG(monetary), 2) AS avg_monetary,
    ROUND(AVG(recency), 1) AS avg_recency_days,
    ROUND(AVG(frequency), 2) AS avg_frequency
FROM rfm_segments
GROUP BY rfm_segment
ORDER BY customer_count DESC;


-- ============================================================
-- 13. HIGH-VALUE CUSTOMERS AT RISK
-- ============================================================

PROMPT
PROMPT 13. HIGH-VALUE CUSTOMERS AT RISK
PROMPT ------------------------------------------------------------

WITH customer_rfm AS
(
    SELECT
        c.customer_unique_id,
        ROUND(
            CAST(
                (SELECT MAX(order_purchase_timestamp) FROM orders)
                AS DATE
            )
            - CAST(MAX(o.order_purchase_timestamp) AS DATE)
        ) AS recency,
        COUNT(DISTINCT o.order_id) AS frequency,
        ROUND(SUM(oi.price), 2) AS monetary
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_unique_id
),
rfm_scores AS
(
    SELECT
        customer_unique_id,
        recency,
        frequency,
        monetary,
        NTILE(5) OVER (ORDER BY recency DESC) AS r_score,
        NTILE(5) OVER (ORDER BY monetary ASC) AS m_score
    FROM customer_rfm
)
SELECT *
FROM
(
    SELECT
        customer_unique_id,
        recency AS days_inactive,
        frequency,
        monetary AS total_spent,
        r_score,
        m_score
    FROM rfm_scores
    WHERE r_score <= 2
      AND m_score >= 4
    ORDER BY monetary DESC
)
FETCH FIRST 20 ROWS ONLY;


-- ============================================================
-- 14. RETENTION & SPEND BY CUSTOMER TYPE
-- ============================================================

PROMPT
PROMPT 14. RETENTION & SPEND BY CUSTOMER TYPE
PROMPT ------------------------------------------------------------

SELECT
    customer_type,
    COUNT(*) AS total_customers,
    ROUND(SUM(total_revenue), 2) AS total_revenue,
    ROUND(AVG(total_revenue), 2) AS average_spend,
    ROUND(AVG(order_count), 2) AS average_orders
FROM
(
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count,
        SUM(oi.price) AS total_revenue,
        CASE
            WHEN COUNT(DISTINCT o.order_id) = 1 THEN 'One-Time Buyer'
            ELSE 'Repeat Buyer'
        END AS customer_type
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_unique_id
)
GROUP BY customer_type
ORDER BY total_revenue DESC;


-- ============================================================
-- 15. MONTHLY NEW CUSTOMER ACQUISITION
-- ============================================================

PROMPT
PROMPT 15. MONTHLY NEW CUSTOMER ACQUISITION
PROMPT ------------------------------------------------------------

SELECT
    TO_CHAR(first_purchase, 'YYYY-MM') AS acquisition_month,
    COUNT(*) AS new_customers
FROM
(
    SELECT
        c.customer_unique_id,
        MIN(o.order_purchase_timestamp) AS first_purchase
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
)
GROUP BY TO_CHAR(first_purchase, 'YYYY-MM')
ORDER BY acquisition_month;


-- ============================================================
-- 16. MONTHLY REPEAT BUYER TRANSACTIONS
-- ============================================================

PROMPT
PROMPT 16. MONTHLY REPEAT BUYER TRANSACTIONS
PROMPT ------------------------------------------------------------

SELECT
    order_month,
    COUNT(DISTINCT customer_unique_id) AS repeat_buyers_active,
    COUNT(order_id) AS repeat_orders_placed
FROM
(
    SELECT
        c.customer_unique_id,
        o.order_id,
        TO_CHAR(o.order_purchase_timestamp, 'YYYY-MM') AS order_month
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    WHERE EXISTS
    (
        SELECT 1
        FROM orders p
        JOIN customers cp
            ON p.customer_id = cp.customer_id
        WHERE cp.customer_unique_id = c.customer_unique_id
          AND p.order_purchase_timestamp < o.order_purchase_timestamp
    )
)
GROUP BY order_month
ORDER BY order_month;


-- ============================================================
-- 17. CUSTOMER RETENTION SUMMARY CARD
-- ============================================================

PROMPT
PROMPT 17. CUSTOMER RETENTION SUMMARY
PROMPT ------------------------------------------------------------

SELECT
    COUNT(*) AS total_unique_customers,
    SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) AS repeat_customers,
    SUM(CASE WHEN order_count = 1 THEN 1 ELSE 0 END) AS one_time_customers,
    ROUND(
        100.0 * SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS repeat_customer_percentage
FROM
(
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
);


-- ============================================================
-- 18. MONTHLY COHORT RETENTION RATES (DETAILED COHORTS)
-- ============================================================

PROMPT
PROMPT 18. MONTHLY COHORT RETENTION RATES
PROMPT ------------------------------------------------------------

WITH customer_cohort AS
(
    SELECT
        c.customer_unique_id,
        MIN(TRUNC(o.order_purchase_timestamp, 'MM')) AS cohort_month
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    WHERE o.order_purchase_timestamp IS NOT NULL
      AND o.order_status <> 'canceled'
    GROUP BY c.customer_unique_id
),
customer_activities AS
(
    SELECT
        c.customer_unique_id,
        cc.cohort_month,
        TRUNC(o.order_purchase_timestamp, 'MM') AS activity_month,
        ROUND(MONTHS_BETWEEN(TRUNC(o.order_purchase_timestamp, 'MM'), cc.cohort_month)) AS month_number
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    JOIN customer_cohort cc
        ON c.customer_unique_id = cc.customer_unique_id
    WHERE o.order_status <> 'canceled'
),
cohort_size AS
(
    SELECT
        cohort_month,
        COUNT(DISTINCT customer_unique_id) AS total_users
    FROM customer_cohort
    GROUP BY cohort_month
),
retention_counts AS
(
    SELECT
        ca.cohort_month,
        ca.month_number,
        COUNT(DISTINCT ca.customer_unique_id) AS retained_users
    FROM customer_activities ca
    GROUP BY ca.cohort_month, ca.month_number
)
SELECT
    TO_CHAR(cs.cohort_month, 'YYYY-MM') AS cohort_month,
    cs.total_users AS cohort_size,
    rc.month_number,
    rc.retained_users,
    ROUND(rc.retained_users * 100.0 / cs.total_users, 2) AS retention_rate_pct
FROM cohort_size cs
JOIN retention_counts rc
    ON cs.cohort_month = rc.cohort_month
WHERE cs.cohort_month >= TO_DATE('2017-01-01', 'YYYY-MM-DD')
  AND cs.cohort_month <= TO_DATE('2017-12-01', 'YYYY-MM-DD')
  AND rc.month_number BETWEEN 1 AND 6
ORDER BY cs.cohort_month, rc.month_number;


-- ============================================================
-- 19. MONTHLY COHORT RETENTION MATRIX (PIVOTED TABLE)
-- ============================================================

PROMPT
PROMPT 19. MONTHLY COHORT RETENTION MATRIX (MONTHS 0 TO 6 %)
PROMPT ------------------------------------------------------------

WITH customer_cohort AS
(
    SELECT
        c.customer_unique_id,
        MIN(TRUNC(o.order_purchase_timestamp, 'MM')) AS cohort_month
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    WHERE o.order_purchase_timestamp IS NOT NULL
      AND o.order_status <> 'canceled'
    GROUP BY c.customer_unique_id
),
customer_activities AS
(
    SELECT
        c.customer_unique_id,
        cc.cohort_month,
        ROUND(MONTHS_BETWEEN(TRUNC(o.order_purchase_timestamp, 'MM'), cc.cohort_month)) AS month_number
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    JOIN customer_cohort cc
        ON c.customer_unique_id = cc.customer_unique_id
    WHERE o.order_status <> 'canceled'
),
cohort_size AS
(
    SELECT
        cohort_month,
        COUNT(DISTINCT customer_unique_id) AS total_users
    FROM customer_cohort
    GROUP BY cohort_month
),
retention_counts AS
(
    SELECT
        ca.cohort_month,
        ca.month_number,
        COUNT(DISTINCT ca.customer_unique_id) AS retained_users
    FROM customer_activities ca
    GROUP BY ca.cohort_month, ca.month_number
)
SELECT
    TO_CHAR(cs.cohort_month, 'YYYY-MM') AS cohort_month,
    cs.total_users AS cohort_size,
    MAX(CASE WHEN rc.month_number = 0 THEN 100.0 END) AS m0_pct,
    NVL(MAX(CASE WHEN rc.month_number = 1 THEN ROUND(rc.retained_users * 100.0 / cs.total_users, 2) END), 0.00) AS m1_pct,
    NVL(MAX(CASE WHEN rc.month_number = 2 THEN ROUND(rc.retained_users * 100.0 / cs.total_users, 2) END), 0.00) AS m2_pct,
    NVL(MAX(CASE WHEN rc.month_number = 3 THEN ROUND(rc.retained_users * 100.0 / cs.total_users, 2) END), 0.00) AS m3_pct,
    NVL(MAX(CASE WHEN rc.month_number = 4 THEN ROUND(rc.retained_users * 100.0 / cs.total_users, 2) END), 0.00) AS m4_pct,
    NVL(MAX(CASE WHEN rc.month_number = 5 THEN ROUND(rc.retained_users * 100.0 / cs.total_users, 2) END), 0.00) AS m5_pct,
    NVL(MAX(CASE WHEN rc.month_number = 6 THEN ROUND(rc.retained_users * 100.0 / cs.total_users, 2) END), 0.00) AS m6_pct
FROM cohort_size cs
JOIN retention_counts rc
    ON cs.cohort_month = rc.cohort_month
WHERE cs.cohort_month >= TO_DATE('2017-01-01', 'YYYY-MM-DD')
  AND cs.cohort_month <= TO_DATE('2017-12-01', 'YYYY-MM-DD')
GROUP BY cs.cohort_month, cs.total_users
ORDER BY cs.cohort_month;


-- ============================================================
-- RETENTION & RFM ANALYSIS COMPLETE
-- ============================================================

PROMPT
PROMPT ============================================================
PROMPT RETENTION AND RFM ANALYSIS COMPLETED SUCCESSFULLY
PROMPT ============================================================
