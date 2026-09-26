# Brazilian E-Commerce Public Dataset by Olist (Raw Data)

This directory contains the original raw data files from the **Brazilian E-Commerce Public Dataset by Olist**, published on Kaggle. The dataset encompasses approximately 100,000 anonymized orders placed between 2016 and 2018 across multiple marketplaces in Brazil.

---

## 📊 Dataset Catalog & File Summary

| File Name | Description | Key Identifier(s) | Records |
| :--- | :--- | :--- | :--- |
| `olist_orders_dataset.csv` | Core order entity tracking status and key fulfillment timestamps. | `order_id`, `customer_id` | 99,441 |
| `olist_customers_dataset.csv` | Customer location details (city, state, zip prefix). | `customer_id`, `customer_unique_id` | 99,441 |
| `olist_order_items_dataset.csv` | Line items per order including pricing, shipping limit, and freight. | `order_id`, `order_item_id`, `product_id`, `seller_id` | 112,650 |
| `olist_order_payments_dataset.csv` | Payment transaction records, installments, and payment types. | `order_id`, `payment_sequential` | 103,886 |
| `olist_order_reviews_dataset.csv` | Customer ratings (1-5), review timestamps, and customer comments. | `review_id`, `order_id` | 99,224 |
| `olist_products_dataset.csv` | Product dimensions, weight, photos quantity, and category names. | `product_id` | 32,951 |
| `olist_sellers_dataset.csv` | Merchant location details (city, state, zip prefix). | `seller_id` | 3,095 |
| `olist_geolocation_dataset.csv` | Brazilian zip code prefixes mapped to latitude and longitude coordinates. | `geolocation_zip_code_prefix` | 1,000,163 |
| `product_category_name_translation.csv` | Translation lookup table mapping Portuguese category names to English. | `product_category_name` | 71 |

---

## 🔗 Relational Entity Relationships

```
                     ┌───────────────────┐
                     │     customers     │
                     └─────────┬─────────┘
                               │ (1:N)
                               ▼
┌───────────────────┐ (1:N) ┌───────────────────┐ (1:N) ┌───────────────────┐
│   order_reviews   │◄──────┤      orders       ├──────►│  order_payments   │
└───────────────────┘       └─────────┬─────────┘       └───────────────────┘
                                      │ (1:N)
                                      ▼
                            ┌───────────────────┐
                            │    order_items    │
                            └────┬─────────┬────┘
                           (N:1) │         │ (N:1)
                                 ▼         ▼
                      ┌──────────────┐ ┌──────────────┐
                      │   products   │ │   sellers    │
                      └──────┬───────┘ └──────────────┘
                             │ (N:1)
                             ▼
             ┌────────────────────────────────┐
             │  product_category_translation  │
             └────────────────────────────────┘
```

---

## 📝 Important Notes & Domain Context
1. **Customer Identifiers:**
   - `customer_id`: Unique identifier per order (a customer placing 3 orders will have 3 distinct `customer_id`s).
   - `customer_unique_id`: Persistent identifier for an individual customer across repeated transactions (crucial for RFM and cohort analysis).
2. **Order Lifecycle & Delivery Statuses:**
   - `delivered`, `shipped`, `canceled`, `invoiced`, `processing`, `unavailable`.
   - Delivered orders represent the primary cohort for revenue calculations.
3. **Currency & Localization:**
   - All financial amounts are denominated in Brazilian Real (BRL / R$).
   - Timestamps are recorded in local Brazilian time (BRT / UTC-3).
