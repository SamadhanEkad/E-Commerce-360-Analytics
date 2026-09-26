OPTIONS (SKIP=1)

LOAD DATA

INFILE "C:\Users\Sam\OneDrive\Documents\PROJECTS\DataAnalyst\E-Commerce-360-Analytics\data\processed\orders.csv"

INTO TABLE orders
APPEND

FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS

(
    order_id CHAR,
    customer_id CHAR,
    order_status CHAR,
    order_purchase_timestamp TIMESTAMP "YYYY-MM-DD HH24:MI:SS",
    order_approved_at TIMESTAMP "YYYY-MM-DD HH24:MI:SS",
    order_delivered_carrier_date TIMESTAMP "YYYY-MM-DD HH24:MI:SS",
    order_delivered_customer_date TIMESTAMP "YYYY-MM-DD HH24:MI:SS",
    order_estimated_delivery_date TIMESTAMP "YYYY-MM-DD HH24:MI:SS"
)