
SELECT  
	 review_comment_message,
     review_score, 
	 customer_zip_code_prefix,
    state_name,
    (SELECT review_score WHERE review_comment_message Not in('bom', 'otimo', 'gostei', 'recomendo', 'excelente')) as other_revs,
    ROUND(AVG(review_score) OVER (PARTITION BY state_name),1)AS avg_review,
    ROW_NUMBER() OVER (PARTITION BY state_name ) AS row_num_state
FROM magist.order_reviews
LEFT JOIN orders
ON order_reviews.order_id = orders.order_id
LEFT JOIN customers
ON orders.customer_id = customers.customer_id
LEFT JOIN geo_sta_names
ON customers.customer_zip_code_prefix = geo_sta_names.zip_code_prefix
;

SELECT ROUND(AVG(other_revs),1) AS bad_revs, 
state_name
FROM other
GROUP BY state_name
ORDER BY bad_revs ASC
;
SELECT best_reviews.state_name, bad_revs, avg_review, 
avg_review - bad_revs AS diff
from best_reviews
LEFT JOIN bad_reviews
ON bad_reviews.state_name = best_reviews.state_name
GROUP BY bad_reviews.state_name
ORDER BY diff DESC
;
SELECT best_reviews.state_name, best_reviews.avg_review AS best_reviews, std_revs.avg_review AS std_reviews, 
best_reviews.avg_review - std_revs.avg_review AS diff
from best_reviews
LEFT JOIN std_revs
ON std_revs.state_name = best_reviews.state_name
GROUP BY best_reviews.state_name
ORDER BY diff DESC;


