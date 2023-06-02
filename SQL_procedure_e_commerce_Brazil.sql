DROP PROCEDURE IF EXISTS get_review;
DELIMITER $$
CREATE PROCEDURE get_review(state VARCHAR (40), category VARCHAR(80), p_year INT)
BEGIN
  
SELECT DISTINCT
	YEAR(order_purchase_timestamp) AS purchase_year, 
	order_status, 
	state_name, 
	product_category_name_english AS category_name,
	COUNT(order_items.product_id) OVER (PARTITION BY product_category_name_english, state_name)  AS product_amt,	
    ROUND(AVG(review_score) OVER (PARTITION BY product_category_name_english, state_name),1)AS avg_review
FROM magist.order_reviews
LEFT JOIN orders
ON order_reviews.order_id = orders.order_id
LEFT JOIN customers
ON orders.customer_id = customers.customer_id
LEFT JOIN geo_sta_names
ON customers.customer_zip_code_prefix = geo_sta_names.zip_code_prefix
LEFT JOIN order_items
ON orders.order_id = order_items.order_id
LEFT JOIN product_english
ON order_items.product_id = product_english.product_id
WHERE order_status = 'delivered'
AND state_name = state 
AND product_category_name_english = category 
AND YEAR(order_purchase_timestamp) = p_year
;
END$$
DELIMITER ;

CALL get_review('Rio de Janeiro', 'health_beauty', 2017);