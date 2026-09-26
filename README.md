# E-Commerce 360° Analytics 🛒📊
### End-to-End Enterprise Data Intelligence, Relational Modeling & AI-Powered BI Platform

[![Python](https://img.shields.io/badge/Python-3.12-3776AB?logo=python&logoColor=white)](https://www.python.org/)
[![Database](https://img.shields.io/badge/Database-Oracle%2021c%20%7C%20SQLite-F80000?logo=oracle&logoColor=white)](https://www.oracle.com/database/)
[![Framework](https://img.shields.io/badge/BI%20App-Streamlit-FF4B4B?logo=streamlit&logoColor=white)](https://streamlit.io/)
[![LLM](https://img.shields.io/badge/AI%20Engine-Google%20Gemini-4285F4?logo=google&logoColor=white)](https://ai.google.dev/)
[![Status](https://img.shields.io/badge/Project%20Status-Completed-10B981)](#)

---

## 📌 Executive Overview

**E-Commerce 360° Analytics** is a comprehensive, production-grade business intelligence and data engineering portfolio project. Built on the Brazilian Olist E-Commerce dataset encompassing **100,000 real orders** from 2016 to 2018, this platform unifies data across 9 relational entities to deliver 360° visibility into revenue trends, fulfillment bottlenecks, customer lifetime behavior, and marketplace dynamics.

The solution spans the full analytics lifecycle:
1. **Automated ETL & Data Cleansing** in Python (Pandas/NumPy).
2. **Feature Engineering** (Logistics SLAs, RFM scores, seller metrics).
3. **Relational Database Modeling** (3NF Schema with Oracle 21c XE & SQLite).
4. **Advanced Analytical SQL Suite** (KPIs, retention cohorts, Pareto analysis).
5. **Excel Management MIS** with interactive pivot tables and executive summaries.
6. **AI Analytics Assistant** featuring a Natural Language to SQL (Text-to-SQL) engine powered by Google Gemini and Streamlit.

---

## 🎯 Executive KPI Scorecard

| Metric | Measured Value | Business Context |
| :--- | :--- | :--- |
| **Gross Payment Volume** | **R$ 15.84M** | Total processed transaction volume across 103.8k payments. |
| **Delivered GMV** | **R$ 13.59M** | Total merchandise value of successfully delivered shipments. |
| **Total Orders** | **99,441** | 96,478 delivered (97.02% fulfillment success rate). |
| **Average Order Value (AOV)** | **R$ 137.75** | Product value per order (R$ 159.85 inclusive of freight). |
| **On-Time Delivery SLA** | **93.2%** | Orders arriving on or before estimated target date. |
| **Average Delivery Cycle** | **12.5 Days** | Transit duration from purchase timestamp to customer doorstep. |
| **Customer Retention Rate** | **3.1%** | Proportion of unique buyers completing 2 or more orders. |
| **Review Score SLA Impact** | **4.29 vs. 2.26** | **-47.3% CSAT drop** on orders experiencing delivery delays. |

---

## 🏗️ System Architecture

![System Architecture](docs/architecture.png)

```
[ Kaggle Raw Data (9 CSVs) ]
             │
             ▼
┌─────────────────────────┐
│ Python Processing Layer │  Cleaning, Datetime Normalization, Imputation,
│ (Pandas, NumPy, EDA)    │  Feature Engineering (Delivery Days, RFM Scoring)
└────────────┬────────────┘
             ▼
┌─────────────────────────┐
│   Relational Storage    │  Oracle Database 21c XE & SQLite (3NF Normalized)
│   (data/ecommerce.db)   │  High-speed B-Tree Indexes & Referential Constraints
└────────────┬────────────┘
             ▼
┌─────────────────────────┐
│   Advanced SQL Suite    │  Data Validation, Executive KPIs, Cohort Retention,
│   (sql/*.sql)           │  Sales Seasonality, RFM Segmentation, Logistics SLA
└────────────┬────────────┘
             ▼
┌──────────────────────────────────────────────────────────────────┐
│                    Business Intelligence Layer                   │
├──────────────────────────────────┬───────────────────────────────┤
│ Excel Management MIS             │ AI Analytics Assistant        │
│ (`excel/ecommerce_management...`)│ (`ai_assistant/app.py`)       │
│ Pivot tables, KPI cards, trends  │ Natural Language to SQL & BI  │
└──────────────────────────────────┴───────────────────────────────┘
```

---

## 📁 Repository Directory Structure

```
E-Commerce-360-Analytics/
├── README.md                                 # Master repository documentation & portfolio guide
├── requirements.txt                          # Python dependencies & libraries
├── .gitignore                                # Version control exclusions
│
├── data/
│   ├── raw/                                  # Original Kaggle datasets (9 CSVs)
│   │   ├── olist_orders_dataset.csv
│   │   ├── olist_customers_dataset.csv
│   │   ├── olist_order_items_dataset.csv
│   │   ├── olist_order_payments_dataset.csv
│   │   ├── olist_order_reviews_dataset.csv
│   │   ├── olist_products_dataset.csv
│   │   ├── olist_sellers_dataset.csv
│   │   ├── olist_geolocation_dataset.csv
│   │   ├── product_category_name_translation.csv
│   │   └── README.md                         # Detailed schema & entity documentation
│   │
│   ├── processed/                            # Cleaned, standardized, & feature-engineered CSVs
│   └── ecommerce.db                          # Hydrated SQLite database with analytical indexes
│
├── python/
│   ├── 01_data_understanding.ipynb           # Initial dataset auditing & profiling
│   ├── 02_data_cleaning.ipynb                # Null imputation, type conversions, deduplication
│   ├── 03_eda.ipynb                          # Exploratory data analysis, distributions, correlations
│   ├── 04_feature_engineering.ipynb          # Calculation of delivery SLAs, RFM scores, & seller KPIs
│   └── 04_data_quality_checks.ipynb          # Automated schema validation & referential integrity suite
│
├── sql/
│   ├── 01_database_schema.sql                # DDL scripts creating 3NF normalized tables
│   ├── 02_load_data.sql                      # SQL*Loader loading scripts
│   ├── 03_data_validation.sql                # Referential integrity & orphan record validation
│   ├── 04_kpi_analysis.sql                   # Executive KPI scorecards (GMV, AOV, Delivery Time)
│   ├── 05_sales_analysis.sql                 # Sales seasonality, MoM trends, & product revenue
│   ├── 06_customer_analysis.sql              # Geographic concentration & customer spend deciles
│   ├── 07_retention_rfm_analysis.sql         # Monthly cohort retention matrix & RFM segmentation
│   └── 08_advanced_analysis.sql              # Logistics SLA impact on CSAT, seller concentration
│
├── excel/
│   └── ecommerce_management_mis.xlsx         # Management Information System (MIS) with pivot charts
│
├── powerbi/
│   └── ecommerce_360_dashboard.pbix          # Power BI dashboard (reserved for final phase)
│
├── ai_assistant/
│   ├── app.py                                # Dual-mode UI (Streamlit Web App + Terminal CLI)
│   ├── sql_generator.py                      # Google Gemini LLM engine & query auto-repair
│   ├── database.py                           # SQLite connection manager & query execution
│   ├── prompts.py                            # Relational schema prompts & few-shot examples
│   ├── validator.py                          # Read-only enforcement & SQL injection security
│   └── README.md                             # AI Assistant user guide & architecture
│
├── reports/
│   ├── business_report.pdf                   # 3-page executive presentation & strategic brief
│   ├── data_dictionary.xlsx                  # Enterprise multi-sheet schema data dictionary
│   └── dashboard_screenshots/                # Visual captures of analytical dashboards
│
└── docs/
    ├── project_pipeline.md                   # End-to-end data pipeline architectural documentation
    ├── business_questions.md                 # Detailed catalog of all business questions addressed
    ├── business_insights.md                  # Executive findings, RFM distribution, & action plan
    └── architecture.png                      # High-resolution architectural diagram
```

---

## 🤖 AI Analytics Assistant (Text-to-SQL)

The repository features an **AI Analytics Assistant** enabling business users to query the database using natural English:

```
[ User Prompt ] ➔ "What are the top 5 product categories by revenue?"
         │
         ▼
[ AI Engine ]   ➔ Generates SQLite query using few-shot schema context
         │
         ▼
[ Validator ]   ➔ Strictly verifies read-only rules (blocks DDL/DML, injection)
         │
         ▼
[ Execution ]   ➔ Runs query on SQLite database (`data/ecommerce.db`)
         │
         ▼
[ Delivery ]    ➔ Renders formatted data table, auto-charts, & AI executive brief
```

### How to Run:
- **Interactive Web App (Streamlit):**
  ```bash
  streamlit run ai_assistant/app.py
  ```
- **Terminal CLI Mode:**
  ```bash
  python ai_assistant/app.py
  ```

---

## 🚀 Getting Started & Installation

### 1. Clone Repository & Setup Environment
```bash
git clone https://github.com/SamadhanEkad/E-Commerce-360-Analytics.git
cd E-Commerce-360-Analytics

# Create and activate virtual environment
python -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
```

### 2. Configure API Key (Optional)
To enable real-time Gemini AI query generation, add your API key to a `.env` file in the root directory:
```env
GEMINI_API_KEY=your_gemini_api_key_here
```
*(The system features an offline catalog mode and can be tested immediately even without an API key).*

### 3. Initialize SQLite Database
The SQLite database automatically hydrates from processed CSVs upon running the assistant or via:
```bash
python -c "from ai_assistant.database import init_database; init_database(verbose=True)"
```

---

## 💡 Key Strategic Insights & Recommendations

1. **Decentralize Logistics with Regional Hubs:**
   - 70.8% of seller capacity resides in São Paulo and Paraná, while delivery transit times to Northern/Northeastern states (BA, CE, PE, PA) average **20 to 28 days**. Establishing 3PL cross-docking fulfillment hubs in Salvador and Recife will cut lead times by 35-40%.
2. **Automate Post-Purchase Re-Engagement:**
   - Customer retention stands at 3.1%. Deploying category-specific replenishment reminders (Health & Beauty, Pet Shop) alongside time-limited 10% second-order discount vouchers within 21 days can elevate repeat rates toward an 8-10% industry standard.
3. **Proactive Delivery Exception Interventions:**
   - On-time orders average **4.29 stars**, while late orders collapse to **2.26 stars**. Setting up automated carrier delay webhooks to issue proactive apologies and R$ 20 wallet credits prior to delivery directly mitigates 1-star review volumes.

---

## 👥 Author & Acknowledgements
- **Author:** Samadhan Ekad
- **Dataset:** [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) (Kaggle)
- **License:** MIT
