# MySQL_Script
##MySQL scripts to retrieve different data from MySQL database
###Question 1: 
Given a table of rental property searches by users. The table consists of search results and outputs host information for searchers. Find the minimum, average, maximum rental prices for each host’s popularity rating. The host’s popularity rating is defined as below:
    0 reviews: New
    1 to 5 reviews: Rising
    6 to 15 reviews: Trending Up
    16 to 40 reviews: Popular
    More than 40 reviews: Hot

###Solution: 
Step 1: Create new host_id by combining price, room_type, host_since, zipcode, and number_of_reviews.
Step 2: Use CASE WHEN to make scenarios and aggregate data using MIN, AVG, MAX

``
WITH T1 AS (
    SELECT CONCAT(price,room_type,host_since,zipcode,number_of_reviews) AS host_id,
    number_of_reviews,price
    FROM airbnb_host_searches
    GROUP BY 1,2,3)``
   
``
SELECT (CASE WHEN number_of_reviews = 0 THEN 'new'
        WHEN number_of_reviews BETWEEN 1 AND 5 THEN 'rising'
        WHEN number_of_reviews BETWEEN 6 AND 15 THEN 'trending up'
        WHEN number_of_reviews BETWEEN 16 AND 40 THEN 'popular'
        WHEN number_of_reviews > 40 THEN 'hot' END) AS rtype,
        MIN(price),AVG(price),MAX(price)
FROM T1
GROUP BY rtype``

##Question 2: 
Find the customer with the highest daily total order cost between 2019-02-01 to 2019-05-01. If customer had more than one order on a certain day, sum the order costs on daily basis. Output customer's first name, total cost of their items, and the date.

###Solution:
Step 1: JOIN two tables using common key, clarify the desired period in WHERE clause
Step 2: In the HAVING clause, filter down to the highest daily total cost by letting the SUM of total order cost equal the MAX of total order cost

``
SELECT first_name,
       sum(total_order_cost) AS total_order_cost,
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
               order_date) b)``

##Question 3: 
Find the top 5 states with the most 5-star businesses. Output the state name along with the number of 5-star businesses and order records by the number of 5-star businesses in descending order. In case there are ties in the number of businesses, return all the unique states. If two states have the same result, sort them in alphabetical order.

###Solution: 
Step 1: Create a CTE table to count number of 5-star restaurants in each state
Step 2: RANK the CTE table ORDER BY star_count WHERE rank <= 5

``
WITH T1 AS (SELECT state,COUNT(stars) as star_count
FROM yelp_business
WHERE stars = 5
GROUP BY state)``

``
SELECT state,star_count
FROM (SELECT *, RANK () OVER (ORDER BY star_count DESC) AS rnk
        FROM T1) a
WHERE rnk <= 5
ORDER BY star_count DESC,state ASC;``

##Question 4: 
Given a table of purchases by date, calculate the month-over-month percentage change in revenue. The output should include the year-month date (YYYY-MM) and percentage change, rounded to the 2nd decimal point, and sorted from the beginning of the year to the end of the year.

###Solution:
Step 1: SUM revenue by month
Step 2: Calculate percentage change using LAG

``
WITH T1 AS 
    (SELECT DATE_FORMAT(created_at, '%Y-%m') AS date, 
    SUM(value) AS revenue
FROM sf_transactions
GROUP BY date)``

``
SELECT date, 
    ROUND(((revenue - prev_revenue) / prev_revenue)*100, 2) AS revenue_diff_pct
FROM
    (SELECT date, revenue, LAG(revenue, 1) over(ORDER BY date) AS prev_revenue
    FROM T1) sub_1;``
