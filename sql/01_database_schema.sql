-- ============================================================
-- E-Commerce 360° Analytics
-- File: 01_database_schema.sql
-- Purpose: Create relational database schema
-- Database: Oracle Database 21c XE
-- ============================================================


-- ============================================================
-- 1. CUSTOMERS
-- ============================================================

CREATE TABLE customers (
    customer_id VARCHAR2(50) PRIMARY KEY,
    customer_unique_id VARCHAR2(50),
    customer_zip_code_prefix NUMBER,
    customer_city VARCHAR2(100),
    customer_state VARCHAR2(10)
);


-- ============================================================
-- 2. ORDERS
-- ============================================================

CREATE TABLE orders (
    order_id VARCHAR2(50) PRIMARY KEY,
    customer_id VARCHAR2(50),
    order_status VARCHAR2(30),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP,
    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);


-- ============================================================
-- 3. PRODUCTS
-- ============================================================

CREATE TABLE products (
    product_id VARCHAR2(50) PRIMARY KEY,
    product_category_name VARCHAR2(100),
    product_name_lenght NUMBER,
    product_description_lenght NUMBER,
    product_photos_qty NUMBER,
    product_weight_g NUMBER,
    product_length_cm NUMBER,
    product_height_cm NUMBER,
    product_width_cm NUMBER
);


-- ============================================================
-- 4. SELLERS
-- ============================================================

CREATE TABLE sellers (
    seller_id VARCHAR2(50) PRIMARY KEY,
    seller_zip_code_prefix NUMBER,
    seller_city VARCHAR2(100),
    seller_state VARCHAR2(10)
);


-- ============================================================
-- 5. ORDER ITEMS
-- ============================================================

CREATE TABLE order_items (
    order_id VARCHAR2(50),
    order_item_id NUMBER,
    product_id VARCHAR2(50),
    seller_id VARCHAR2(50),
    shipping_limit_date TIMESTAMP,
    price NUMBER(10,2),
    freight_value NUMBER(10,2),
    CONSTRAINT pk_order_items
        PRIMARY KEY (order_id, order_item_id),
    CONSTRAINT fk_order_items_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id),
    CONSTRAINT fk_order_items_product
        FOREIGN KEY (product_id)
        REFERENCES products(product_id),
    CONSTRAINT fk_order_items_seller
        FOREIGN KEY (seller_id)
        REFERENCES sellers(seller_id)
);


-- ============================================================
-- 6. ORDER PAYMENTS
-- ============================================================

CREATE TABLE order_payments (
    order_id VARCHAR2(50),
    payment_sequential NUMBER,
    payment_type VARCHAR2(30),
    payment_installments NUMBER,
    payment_value NUMBER(10,2),
    CONSTRAINT pk_order_payments
        PRIMARY KEY (order_id, payment_sequential),
    CONSTRAINT fk_order_payments_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
);


-- ============================================================
-- 7. ORDER REVIEWS
-- ============================================================

CREATE TABLE order_reviews (
    review_id VARCHAR2(50),
    order_id VARCHAR2(50),
    review_score NUMBER,
    review_comment_title VARCHAR2(500),
    review_comment_message VARCHAR2(4000),
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP,
    CONSTRAINT pk_order_reviews
        PRIMARY KEY (review_id, order_id),
    CONSTRAINT fk_order_reviews_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
);


-- ============================================================
-- 8. PRODUCT CATEGORY TRANSLATION
-- ============================================================

CREATE TABLE product_category_translation (
    product_category_name VARCHAR2(100) PRIMARY KEY,
    product_category_name_english VARCHAR2(100)
);


-- ============================================================
-- 9. GEOLOCATION
-- ============================================================

CREATE TABLE geolocation (
    geolocation_zip_code_prefix NUMBER,
    geolocation_lat NUMBER(10,7),
    geolocation_lng NUMBER(10,7),
    geolocation_city VARCHAR2(100),
    geolocation_state VARCHAR2(10)
);


-- ============================================================
-- 10. HIGH-SPEED ANALYTICAL & PERFORMANCE INDEXES
-- ============================================================

-- Foreign Key Indexes (Accelerates Joins across Relational Schema)
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);
CREATE INDEX idx_order_items_seller ON order_items(seller_id);
CREATE INDEX idx_order_payments_order ON order_payments(order_id);
CREATE INDEX idx_order_reviews_order ON order_reviews(order_id);

-- Filter & Analytical Search Indexes (Accelerates WHERE / GROUP BY / Window Functions)
CREATE INDEX idx_orders_status ON orders(order_status);
CREATE INDEX idx_orders_purchase_timestamp ON orders(order_purchase_timestamp);
CREATE INDEX idx_customers_unique_id ON customers(customer_unique_id);
CREATE INDEX idx_products_category ON products(product_category_name);
CREATE INDEX idx_geolocation_zip ON geolocation(geolocation_zip_code_prefix);


-- ============================================================
-- SCHEMA CREATION COMPLETE
-- ============================================================

PROMPT ============================================================
PROMPT Database schema & analytical indexes created successfully.
PROMPT ============================================================