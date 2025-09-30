DROP TABLE IF EXISTS customer_journey;
CREATE TABLE customer_journey
(      journey_id INT  ,
       customer_id INT ,
	   product_id INT  ,
	   visit_date DATE ,
	   stage VARCHAR(20),
	   action VARCHAR(15),
	   duration INT 
)  
SELECT * FROM customer_journey


DROP TABLE IF EXISTS customer_reviews
CREATE TABLE customer_reviews
(      review_id INT     ,
       customer_id INT   ,
	   product_id  INT   ,
	   review_date DATE  ,
	   rating INT        , 
	   review_text VARCHAR(75)
)
SELECT * FROM customer_reviews


DROP TABLE IF EXISTS customers
CREATE TABLE customers
(      customer_id INT    ,
       customer_name VARCHAR(30) , 
	   email VARCHAR(50) ,
	   gender VARCHAR(10) , 
	   age INT , 
	   geography_id INT 
)
SELECT * FROM customers


DROP TABLE IF EXISTS engagement_data
CREATE TABLE engagement_data
(      engagement_id INT , 
       content_id INT ,
	   content_type VARCHAR(20) ,
	   likes INT , 
	   engagement_date DATE , 
	   campaign_id INT , 
	   product_id INT , 
	   views_clicks_combined VARCHAR(20)
)
SELECT * FROM engagement_data


DROP TABLE IF EXISTS geography
CREATE TABLE geography
(      geography_id INT , 
       country VARCHAR(20),
	   city VARCHAR (20)
)
SELECT * FROM geography


DROP TABLE IF EXISTS products
CREATE TABLE products
(      product_id INT , 
       product_name VARCHAR(20) , 
	   category VARCHAR(20) , 
	   price FLOAT
)
SELECT * FROM products


SELECT * FROM customer_journey
SELECT * FROM customer_reviews
SELECT * FROM customers
SELECT * FROM engagement_data
SELECT * FROM geography
SELECT * FROM products


-- Query to categorised products based on their prize 
SELECT product_id ,           
       product_name ,          
	   price ,                
-- Now we will categorozid the products
CASE 
    WHEN price < 50 THEN 'LOW'
	WHEN price > 51 AND price < 200 THEN 'MEDIUM'
	ELSE 'HIGH'
END AS price_category
FROM products


-- Query to join customers with geography because marketing analysis ke liye customer location is an imp factor 
SELECT c.customer_id , c.customer_name , c.email , c.gender , c.age ,
       g.country , g.city 
FROM customers AS c  -- INNER JOIN means dono tables ke matchinhg rows ko jodna (join karna)
LEFT JOIN geography AS g 
ON c.geography_id = g.geography_id -- common coumn on which join is performed


-- Query to clean whitespace issue in review text colum
SELECT TRIM(review_text) AS trimmed_text FROM customer_reviews
SELECT LENGTH(review_text)AS length FROM customer_reviews
SELECT LENGTH(TRIM(review_text))AS Trimmed_length FROM customer_reviews

SELECT review_id, customer_id, product_id, review_date, rating,
       REPLACE (review_text, '  ' , ' ') -- replacing 2 spaces with a single space
FROM customer_reviews


-- Query to normalize and clean the table of engagement data 
SELECT * FROM engagement_data 
SELECT DISTINCT(content_type) FROM engagement_data -- this gives all the uniques values from the data 

SELECT engagement_id, content_id, campaign_id, product_id, likes ,    
CASE  -- to make it proper we will use Case function because it does not make changes in original data just give a addition column by fulfulling the conditions
    WHEN LOWER(content_type) = 'newsletter' THEN 'News Letter'
    WHEN LOWER(content_type) = 'socialmedia' THEN 'Social Media'
	WHEN LOWER(content_type) = 'blog' THEN 'Blog'
	WHEN LOWER(content_type) = 'video' THEN 'Video'
    ELSE 'other'
END AS content_type ,
TO_CHAR(engagement_date, 'DD.MM.YYYY') AS proper_date, -- chnaging the format of date 
SPLIT_PART(views_clicks_combined, '-', 1) AS Views,
SPLIT_PART(views_clicks_combined, '-', 2) AS clicks
FROM engagement_data

-- We  can do this in another way also 
SELECT views_clicks_combined ,
LEFT(views_clicks_combined, POSITION('-' IN views_clicks_combined) -1 ) AS Views,
RIGHT(views_clicks_combined, LENGTH(views_clicks_combined) - POSITION('-' IN views_clicks_combined)) AS clicks
FROM engagement_data

 
-- Commmon Table Expresison (CTE) to identify and tag duplicate records
SELECT * FROM customer_journey
WHERE duration IS NULL  -- I randomy did this and found out that in action table drop-off containts alll nulll values in it  

CREATE TEMP TABLE duplly AS 
      SELECT journey_id, customer_id, product_id, visit_date, stage, action, duration, 
       ROW_NUMBER () OVER (
	   PARTITION BY  customer_id, product_id, visit_date, stage, action
	   ORDER BY journey_id)  AS row_ka_number
	   FROM customer_journey

SELECT * FROM duplly

SELECT * FROM duplly 
WHERE row_ka_number > 1
ORDER BY journey_id


-------------   Outer query selects the final cleaned and standardized data
SELECT * FROM customer_journey

SELECT  journey_id, customer_id, product_id, visit_date, "Stage", action, 
        COALESCE (duration, average_duration ) AS  "DURATION" 
FROM 
(    SELECT journey_id, customer_id, product_id, visit_date,
     UPPER(stage) AS "Stage", action, duration,
	 ROUND(AVG(duration) OVER ( PARTITION BY visit_date ),2)  AS  average_duration ,
	 ROW_NUMBER() OVER ( PARTITION BY customer_id, product_id, visit_date, UPPER(stage), action
	 ORDER BY journey_id) AS row_ka_number
	 FROM customer_journey
) AS subquery
WHERE row_ka_number = 1	 


-- Through the below query you can find all the names of table in this databse
SELECT tablename
FROM pg_catalog.pg_tables
WHERE schemaname != 'pg_catalog' AND schemaname != 'information_schema';


