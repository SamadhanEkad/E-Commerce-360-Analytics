OPTIONS (SKIP=1)

LOAD DATA

INFILE "C:\Users\Sam\OneDrive\Documents\PROJECTS\DataAnalyst\E-Commerce-360-Analytics\data\processed\geolocation.csv"

INTO TABLE geolocation
APPEND

FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS

(
    geolocation_zip_code_prefix INTEGER EXTERNAL,
    geolocation_lat DECIMAL EXTERNAL,
    geolocation_lng DECIMAL EXTERNAL,
    geolocation_city CHAR,
    geolocation_state CHAR
)