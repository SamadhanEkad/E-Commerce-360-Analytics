OPTIONS (SKIP=1)

LOAD DATA

INFILE "C:\Users\Sam\OneDrive\Documents\PROJECTS\DataAnalyst\E-Commerce-360-Analytics\data\processed\products.csv"

INTO TABLE products
APPEND

FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS

(
    product_id CHAR,
    product_category_name CHAR,
    product_name_lenght INTEGER EXTERNAL,
    product_description_lenght INTEGER EXTERNAL,
    product_photos_qty INTEGER EXTERNAL,
    product_weight_g DECIMAL EXTERNAL,
    product_length_cm DECIMAL EXTERNAL,
    product_height_cm DECIMAL EXTERNAL,
    product_width_cm DECIMAL EXTERNAL
)