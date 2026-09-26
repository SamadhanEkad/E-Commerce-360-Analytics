# E-Commerce 360° Analytics: Python Pipeline Architecture & Execution Report

**Document Name:** Python Work Master Report  
**Author:** Data Analyst & Analytics Engineering Team  
**Pipeline Stage:** Stage 1: Data Understanding, Cleaning, EDA, Quality Audit & Feature Engineering  
**Status:** Completed & Certified  
**Certified Datasets:** 9 Clean 3NF Tables + 4 Feature-Engineered Datasets  

---

## 📌 1. Executive Summary & Pipeline Context

In the enterprise analytics lifecycle of **E-Commerce 360° Analytics**, Stage 1 handles the end-to-end Python processing pipeline. Raw data comprising 100,000 real-world e-commerce transactions from the Brazilian marketplace (Olist) is audited, cleansed, sanitized, explored, and feature-engineered before entering the relational data warehouse tier.

```
┌─────────────────────────────────┐
│     Raw Data Ingestion          │  9 Raw Olist CSV files (data/raw/*.csv)
│     (data/raw/)                 │  1.0M+ records across orders, customers, items, payments
└────────────────┬────────────────┘
                 │
                 ▼
┌─────────────────────────────────┐
│  01_data_understanding.ipynb    │  Schema profiling, data types, nulls, memory audit,
│  (Data Understanding)           │  identifying customer_id vs customer_unique_id
└────────────────┬────────────────┘
                 │
                 ▼
┌─────────────────────────────────┐
│  02_data_cleaning.ipynb         │  Missing value imputation, newline sanitization,
│  (Data Cleaning & Preprocessing)│  geolocation coordinate deduplication (1M -> 738k)
└────────────────┬────────────────┘
                 │
                 ▼
┌─────────────────────────────────┐
│  03_eda.ipynb                   │  Distribution analysis, sales trends, delivery SLA,
│  (Exploratory Data Analysis)    │  geographic concentration, payment method breakdown
└────────────────┬────────────────┘
                 │
                 ▼
┌─────────────────────────────────┐
│  04_data_quality_checks.ipynb   │  PK uniqueness, FK referential integrity, range checks,
│  (Data Quality & Audit Suite)   │  chronological datetime validation (Zero-defect sign-off)
└────────────────┬────────────────┘
                 │
                 ▼
┌─────────────────────────────────┐
│  05_feature_engineering.ipynb   │  Logistics SLA (delay days), temporal components,
│  (Feature Engineering)          │  RFM metrics, category translation, seller SLA
└────────────────┬────────────────┘
                 │
                 ▼
┌─────────────────────────────────┐
│     Clean Datasets Ready        │  • 9 Normalized 3NF CSVs (data/processed/*.csv)
│     (data/processed/)           │  • 4 Feature-Engineered Datasets (for ML & Power BI)
└─────────────────────────────────┘
```

---

## 📂 2. Notebook Architecture & Deliverable Matrix

Stage 1 is divided into **5 modular, self-contained, reproducible Jupyter Notebooks** located in the `python/` directory:

| # | Notebook File | Focus Area | Inputs | Key Deliverables & Outputs |
| :---: | :--- | :--- | :--- | :--- |
| **01** | `01_data_understanding.ipynb` | Schema & Entity Profiling | `data/raw/*.csv` | `reports/data_understanding_summary.csv`, entity relationship mapping, initial dictionary |
| **02** | `02_data_cleaning.ipynb` | Cleansing & Deduplication | `data/raw/*.csv` | 9 clean 3NF CSVs in `data/processed/`, newline stripping for Oracle SQL*Loader |
| **03** | `03_eda.ipynb` | Deep Exploratory Analytics | `data/processed/*.csv` | Statistical visual plots, fulfillment metrics, payment distributions, geographic maps |
| **04** | `04_data_quality_checks.ipynb` | Quality & Referential Audit | `data/processed/*.csv` | Automated test suite verifying 0 null PKs, 0 duplicate keys, 0 orphan FKs |
| **05** | `05_feature_engineering.ipynb` | Business & ML Features | `data/processed/*.csv` | 4 enriched CSVs with RFM scores, delivery SLA metrics, Brazilian macro-regions |

---

## 🛠️ 3. Step-by-Step File Walkthrough

### 📄 `python/01_data_understanding.ipynb` — Schema & Entity Profiling
- **Objective:** Comprehensively audit the structure, size, column definitions, and entity relationships of the raw dataset.
- **Key Actions & Discoveries:**
  1. **Volume & Footprint:** Audited all 9 files totaling ~1.2M rows and ~120 MB in memory.
  2. **Critical Identity Discovery:** Identified the dual-key customer architecture:
     - `orders.customer_id`: An ephemeral, order-level session surrogate key.
     - `customers.customer_unique_id`: The real human buyer identifier across multiple orders. Grouping by `customer_unique_id` is mandatory to compute true repeat purchase behavior and customer retention.
  3. **Null Profile:** Identified high missingness in review comment fields (58% without titles, 60% without comments) and missing dimensions in a minor subset of products.
- **Output:** Generated `reports/data_understanding_summary.csv`.

---

### 📄 `python/02_data_cleaning.ipynb` — Cleansing, Imputation & Sanitization
- **Objective:** Convert raw, messy data into production-ready, standardized 3NF relational files.
- **Key Cleaning Operations:**
  1. **Missing Value Strategy:**
     - `order_reviews`: Imputed missing review titles with `'No Title'` and comments with `'No Comment'`.
     - `products`: Imputed missing product dimensions (weight, length, height, width) using category-level medians. Assigned `'unknown'` to untranslated product categories.
     - Unfulfilled order timestamps (e.g., undelivered orders) left as structured `NULL` (rather than synthetic dates) to preserve semantic validity.
  2. **Coordinate Deduplication (`geolocation.csv`):**
     - Raw geolocation contained 1,000,163 records with extreme redundancy per zip code.
     - Deduplicated to **738,332 clean records** preserving accurate spatial centroid coordinates.
  3. **SQL*Loader Sanitization:**
     - Raw review comments contained unescaped `\r\n` and `\n` linebreaks that break database bulk loaders (Oracle SQL*Loader, Snowflake, PostgreSQL).
     - Sanitized embedded linebreaks into single-line records, ensuring 100% load success with zero rejected rows.
- **Output:** Saved 9 clean relational CSVs to `data/processed/`.

---

### 📄 `python/03_eda.ipynb` — Exploratory Data Analysis & Statistical Insights
- **Objective:** Conduct rigorous exploratory data analysis to uncover business performance patterns, seasonality, and customer behaviors.
- **Core Findings & Business Insights:**
  1. **Order Fulfillment Performance:**
     - **97.02%** of orders reach `'delivered'` status (96,478 orders).
     - **0.63%** canceled and **0.61%** unavailable.
     - Average delivery turnaround is **12.5 days**, with 92% of orders arriving well before the estimated delivery SLA.
  2. **Sales Trends & Seasonality:**
     - Massive revenue surge in **November 2017 (+52.1% MoM)** driven by Black Friday.
     - Peak purchasing days: **Monday (16.29%)** and **Tuesday (16.05%)**.
     - Peak ordering hours: **10:00 to 16:00** (peaking at 14:00-15:00 with ~6.7% hourly volume).
  3. **Geographic Demand Concentration:**
     - Top 3 states (**SP: 41.6%**, **RJ: 12.8%**, **MG: 11.6%**) account for over **66% of total platform GMV**.
  4. **Payment Preferences:**
     - **Credit Card** dominates with **73.9%** of transaction volume, followed by **Boleto Bancário (19.0%)**, **Voucher (5.6%)**, and **Debit Card (1.5%)**.
     - Credit card orders average **3.5 installments**, with high-value purchases (>R$ 500) stretching up to 10-12 installments.
  5. **Review Score Polarization & Logistics Impact:**
     - Reviews exhibit a classic satisfaction bimodal curve: **5-star reviews account for 57.8%**, while 1-star reviews represent **11.9%**.
     - Late delivery is the single largest driver of customer dissatisfaction: **54% of late orders receive 1 or 2 stars**, resulting in a **-40.1% drop in average CSAT**.

---

### 📄 `python/04_data_quality_checks.ipynb` — Data Quality & Integrity Audit
- **Objective:** Implement a 6-stage test suite certifying data integrity before warehouse loading.
- **Test Results & Verification:**
  - ✅ **Primary Key Uniqueness:** 0 duplicate primary keys across `customers`, `orders`, `products`, `sellers`, `order_items`, and `order_reviews`.
  - ✅ **Primary Key Null Checks:** 0 null values in any primary key.
  - ✅ **Referential Integrity (Foreign Keys):** 0 orphan records across all 5 key relationships:
    - Orders ➔ Customers: 0 orphans
    - Order Items ➔ Orders: 0 orphans
    - Order Items ➔ Products: 0 orphans
    - Order Items ➔ Sellers: 0 orphans
    - Order Reviews ➔ Orders: 0 orphans
  - ✅ **Range & Domain Boundaries:** 0 negative prices, 0 negative freight charges, 0 negative payment amounts; all review scores strictly between 1 and 5.
  - ✅ **Datetime Chronology:** 0 chronological errors (`order_purchase_timestamp <= order_approved_at <= order_delivered_carrier_date <= order_delivered_customer_date`).

---

### 📄 `python/05_feature_engineering.ipynb` — Advanced Feature Engineering
- **Objective:** Compute domain-specific features required for machine learning, RFM customer segmentation, and Power BI reporting.
- **Features Created & Enriched:**
  1. **Temporal Features:** Extracted `order_year`, `order_month`, `order_day_of_week`, `order_hour`, and boolean flag `is_weekend`.
  2. **Logistics & Delivery SLA:**
     - `delivery_turnaround_days`: Actual days from purchase to customer delivery.
     - `estimated_delivery_days`: Promised delivery duration.
     - `delivery_delay_days`: Days delayed past estimated promise date (`delivery_date - estimated_date`).
     - `is_delayed`: Binary indicator (`1` if delivered past estimated date, `0` otherwise).
  3. **Customer RFM & Lifetime Metrics:**
     - **Recency:** Days since customer's most recent order relative to dataset reference date.
     - **Frequency:** Total number of distinct orders placed by human buyer (`customer_unique_id`).
     - **Monetary:** Total cumulative spending (item price + freight) across all orders.
     - **RFM Score & Tiers:** 5-quantile scoring (`NTILE(5)`) segmenting buyers into Champions, Loyal, At-Risk, and Lost.
  4. **Product & Seller Performance Metrics:**
     - English category translation merged directly into products.
     - Product-level sales volume, total GMV, and average review score.
     - Seller-level order fulfillment volume, tenure in days, and on-time delivery rate.
  5. **Geographic Localization:**
     - Brazilian state abbreviations mapped to full state names and 5 macro-regions (Southeast, South, Northeast, Central-West, North).
- **Output:** Exported 4 feature-engineered datasets:
  - `customers_feature_engineered.csv` (99,441 rows, 11 columns)
  - `orders_feature_engineered.csv` (99,441 rows, 27 columns)
  - `products_feature_engineered.csv` (32,951 rows, 14 columns)
  - `sellers_feature_engineered.csv` (3,095 rows, 10 columns)

---

## 📊 4. Dataset Parity & Quality Sign-Off

All outputs generated by Stage 1 match the relational data warehouse tables with 100% integrity:

| Dataset / Table | Rows | Primary Key | Key Uniqueness | Null PKs | Warehouse Parity |
| :--- | :---: | :--- | :---: | :---: | :---: |
| `customers.csv` | **99,441** | `customer_id` | 100% Unique | 0 | ✅ Exact Match |
| `orders.csv` | **99,441** | `order_id` | 100% Unique | 0 | ✅ Exact Match |
| `order_items.csv` | **112,650** | `(order_id, order_item_id)` | 100% Unique | 0 | ✅ Exact Match |
| `order_payments.csv` | **103,886** | `(order_id, payment_sequential)` | 100% Unique | 0 | ✅ Exact Match |
| `order_reviews.csv` | **99,224** | `(review_id, order_id)` | 100% Unique | 0 | ✅ Exact Match |
| `products.csv` | **32,951** | `product_id` | 100% Unique | 0 | ✅ Exact Match |
| `sellers.csv` | **3,095** | `seller_id` | 100% Unique | 0 | ✅ Exact Match |
| `geolocation.csv` | **738,332** | `(zip_code, lat, lng)` | Deduplicated | 0 | ✅ Exact Match |
| `product_category_name_translation.csv` | **71** | `product_category_name` | 100% Unique | 0 | ✅ Exact Match |

---

## 🚀 5. Handoff to Stage 2 (SQL Data Warehouse)

With Stage 1 completed and verified:
1. **Clean 3NF tables** in `data/processed/` are ingested directly into **Oracle Database 21c XE** via `sql/ctl/*.ctl` and **SQLite (`data/ecommerce.db`)**.
2. **Feature-engineered datasets** feed directly into **Power BI (Stage 3)** and statistical modeling.
3. The schema and business rules established in Stage 1 provide the ground truth for our **Gemini AI Assistant (Stage 4)**.
