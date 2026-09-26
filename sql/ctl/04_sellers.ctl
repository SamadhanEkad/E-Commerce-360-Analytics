OPTIONS (SKIP=1)

LOAD DATA

INFILE "C:\Users\Sam\OneDrive\Documents\PROJECTS\DataAnalyst\E-Commerce-360-Analytics\data\processed\sellers.csv"

INTO TABLE sellers
APPEND

FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS

(
    seller_id CHAR,
    seller_zip_code_prefix INTEGER EXTERNAL,
    seller_city CHAR,
    seller_state CHAR
)