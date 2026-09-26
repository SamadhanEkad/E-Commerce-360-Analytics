OPTIONS (SKIP=1)

LOAD DATA

INFILE "C:\Users\Sam\OneDrive\Documents\PROJECTS\DataAnalyst\E-Commerce-360-Analytics\data\processed\order_payments.csv"

INTO TABLE order_payments
APPEND

FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS

(
    order_id CHAR,
    payment_sequential INTEGER EXTERNAL,
    payment_type CHAR,
    payment_installments INTEGER EXTERNAL,
    payment_value DECIMAL EXTERNAL
)