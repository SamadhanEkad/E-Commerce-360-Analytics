OPTIONS (SKIP=1)

LOAD DATA

INFILE "C:\Users\Sam\OneDrive\Documents\PROJECTS\DataAnalyst\E-Commerce-360-Analytics\data\processed\order_items.csv"

INTO TABLE order_items
APPEND

FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS

(
    order_id CHAR,
    order_item_id INTEGER EXTERNAL,
    product_id CHAR,
    seller_id CHAR,
    shipping_limit_date TIMESTAMP "YYYY-MM-DD HH24:MI:SS",
    price DECIMAL EXTERNAL,
    freight_value DECIMAL EXTERNAL
)