#Question 1: AirBnB Host Ratings
WITH T1 AS (
    SELECT CONCAT(price,room_type,host_since,zipcode,number_of_reviews) AS host_id,
    number_of_reviews,price
    FROM airbnb_host_searches
    GROUP BY 1,2,3)

SELECT (CASE WHEN number_of_reviews = 0 THEN 'new'
        WHEN number_of_reviews BETWEEN 1 AND 5 THEN 'rising'
        WHEN number_of_reviews BETWEEN 6 AND 15 THEN 'trending up'
        WHEN number_of_reviews BETWEEN 16 AND 40 THEN 'popular'
        WHEN number_of_reviews > 40 THEN 'hot' END) AS rtype,
        MIN(price),AVG(price),MAX(price)
FROM T1
GROUP BY rtype;

#Question 2: Highest Order Cost
SELECT first_name,
       SUM(total_order_cost) AS total_order_cost,
       order_date
FROM orders o
LEFT JOIN customers c ON o.cust_id = c.id
WHERE order_date BETWEEN '2019-02-1' AND '2019-05-1'
GROUP BY first_name,
         order_date
HAVING SUM(total_order_cost) =
  (SELECT MAX(total_order_cost)
   FROM
     (SELECT SUM(total_order_cost) AS total_order_cost
      FROM orders
      WHERE order_date BETWEEN '2019-02-1' AND '2019-05-1'
      GROUP BY cust_id,
               order_date) b);

#Question 3: 5-star Restaurant Count
WITH T1 AS (SELECT state,COUNT(stars) as star_count
FROM yelp_business
WHERE stars = 5
GROUP BY state)

SELECT state,star_count
FROM (SELECT *, RANK () OVER (ORDER BY star_count DESC) AS rnk
        FROM T1) a
WHERE rnk <= 5
ORDER BY star_count DESC,state ASC;

#Question 4: Percentage of Revenue Change (Monthly)
WITH T1 AS 
    (SELECT DATE_FORMAT(created_at, '%Y-%m') AS date, 
    SUM(value) AS revenue
FROM sf_transactions
GROUP BY date)

SELECT date, 
    ROUND(((revenue - prev_revenue) / prev_revenue)*100, 2) AS revenue_diff_pct
FROM
    (SELECT date, revenue, lag(revenue, 1) over(ORDER BY date) AS prev_revenue
    FROM T1) sub_1;
