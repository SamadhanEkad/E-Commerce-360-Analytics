OPTIONS (SKIP=1)

LOAD DATA

INFILE "C:\Users\Sam\OneDrive\Documents\PROJECTS\DataAnalyst\E-Commerce-360-Analytics\data\processed\order_reviews.csv"

INTO TABLE order_reviews
APPEND

FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS

(
    review_id CHAR(50),
    order_id CHAR(50),
    review_score INTEGER EXTERNAL,
    review_comment_title CHAR(500),
    review_comment_message CHAR(4000),
    review_creation_date TIMESTAMP "YYYY-MM-DD HH24:MI:SS",
    review_answer_timestamp TIMESTAMP "YYYY-MM-DD HH24:MI:SS"
)