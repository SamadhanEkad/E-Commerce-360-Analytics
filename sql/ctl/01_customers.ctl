OPTIONS (SKIP=1)

LOAD DATA

INFILE "C:\Users\Sam\OneDrive\Documents\PROJECTS\DataAnalyst\E-Commerce-360-Analytics\data\processed\customers.csv"

INTO TABLE customers
APPEND

FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS

(
    customer_id CHAR,
    customer_unique_id CHAR,
    customer_zip_code_prefix INTEGER EXTERNAL,
    customer_city CHAR,
    customer_state CHAR
)