SELECT * FROM cm_orders
--Which city has the highest total sales?
SELECT cm_orders."City", ROUNd(SUM(cm_orders.total)::"numeric") as total_sales
from cm_orders
GROUP by cm_orders."City"
ORDER by total_sales desc
limit 5

--What is the average profit margin per category?
SELECT cm_orders.category,round(avg(cm_orders.profit_margin)::numeric,2) as avg_profit_margin
FROM cm_orders
group by cm_orders.category
ORDER by avg_profit_margin DESC

--Which payment method is most used in each branch?

WITH cte AS (
  SELECT 
    "Branch",
    payment_method,
    COUNT(invoice_id) AS txn_count,
    ROW_NUMBER() OVER (PARTITION BY "Branch" ORDER BY COUNT(invoice_id) DESC) AS rn
  FROM cm_orders
  GROUP BY "Branch", payment_method
)
SELECT "Branch",payment_method,txn_count
FROM cte
WHERE rn=1
Order by txn_count desc;


--What are the top 5 categories by total quantity sold?
select category, SUM(quantity) as total_quantity_sold
from cm_orders
group by category
order by total_quantity_sold desc
--What is the hourly sales trend across all stores?
SELECT 
  EXTRACT(HOUR FROM cm_orders.time:: time) AS hour_of_day,
  ROUND(SUM(total)::numeric, 2) AS total_sales
FROM cm_orders
GROUP BY hour_of_day
ORDER BY total_sales desc
LIMIT 5;



📊 --Sales & Revenue Analysis
--What is the total sales across all branches?
SELECT "Branch", ROUND(SUM(total)::Numeric,2) AS sales
FROM cm_orders
GROUP BY "Branch"
ORDER BY sales desc
LIMIT 5;

--Which category has generated the highest revenue?
SELECT DISTINCT "category", ROUND(SUM(total)::numeric) AS revenue
FROM cm_orders
GROUP BY "category"
ORDER BY revenue DESC;

--What is the average order value?
SELECT ROUND(SUM(total)::numeric
/count(distinct invoice_id),2) as avg_order_value
FROM cm_orders


--How much profit is made per category?
SELECT "category", ROUND(SUM(profit_margin)::Numeric, 2) AS total_profit
FROM cm_orders
GROUP BY "category"
ORDER BY total_profit DESC;

--Which branch has the highest number of transactions?
SELECT "Branch", count(invoice_id) AS no_of_transactions
FROM cm_orders
GROUP BY "Branch"
ORDER BY no_of_transactions desc
LIMIT 5;

--What is the monthly trend of total sales?
SELECT TO_CHAR(To_DATE(cm_orders.date,'DD-MM-YY'),'MONTH') as month,ROUND(SUM(total)::Numeric,2) AS sales
FROM cm_orders
group by month
order by sales desc 

-- What is the daily average revenue?
SELECT TO_CHAR(To_DATE(cm_orders.date,'DD-MM-YY'),'DAY') as Day, 
ROUND(SUM(total)::numeric / COUNT(DISTINCT invoice_id), 2) AS avg_daily_revenue
FROM cm_orders
GROUP BY TO_CHAR(To_DATE(cm_orders.date,'DD-MM-YY'),'DAY')


--Which products (unit_price range) contribute the most to sales?
SELECT 
  CASE 
    WHEN unitprice <= 10 THEN '0-10' 
    WHEN unitprice <= 20 THEN '10-20' 
    WHEN unitprice <= 30 THEN '20-30'
    WHEN unitprice <= 40 THEN '30-40'
    WHEN unitprice <= 50 THEN '40-50'
    WHEN unitprice <= 60 THEN '50-60'
    WHEN unitprice <= 70 THEN '60-70'
    WHEN unitprice <= 80 THEN '70-80'
    WHEN unitprice <= 90 THEN '80-90'
    ELSE '90-100' 
  END AS unit_price_range,
  ROUND(SUM(total)::numeric, 2) AS total_sales
FROM cm_orders
GROUP BY unit_price_range
ORDER BY total_sales DESC
LIMIT 1;

--🛒 Customer & Product Behavior

--What is the average quantity sold per invoice?
SELECT ROUND(AVG(total)::numeric, 2)/count(invoice_id) as avg_quant_sold
FROM cm_orders

--Which hour of the day sees the highest sales?
SELECT TO_CHAR(time::time, 'HH24') AS hour,ROUND(SUM(total)::numeric, 2) as total_sales
FROM cm_orders
group by TO_CHAR(time::time, 'HH24') 
order by total_sales DESC

--What is the most sold category during weekends?
SELECT category, SUM(quantity) AS total_quantity
,EXTRACT(DOW FROM TO_DATE(date,'DD-MM-YY')) as DOW
FROM cm_orders
WHERE EXTRACT(DOW FROM TO_DATE(date,'DD-MM-YY')) IN (0,6)
GROUP BY category,EXTRACT(DOW FROM TO_DATE(date,'DD-MM-YY'))
ORDER BY total_quantity DESC
LIMIT 1;
--What is the sales contribution of each payment method?
SELECT payment_method,ROUND(SUM(total)::numeric, 2) as total_sales
FROM cm_orders
group by payment_method

--What are the top 5 product categories with highest unit_price but low sales?
SELECT category, round(avg(unitprice)::numeric,2) as avg_unit_price, ROUND(SUM(total)::numeric, 2) as total_sales
FROM cm_orders
GROUP by category
ORDER BY avg_unit_price DESC, total_sales ASC

--Are customers buying more in mornings or evenings?
SELECT 
  CASE 
    WHEN time::time > '06:00:00' AND time::time < '12:00:00' THEN 'morning'
    WHEN time::time > '18:00:00' AND time::time < '24:00:00' THEN 'evening' 
    ELSE 'other'
  END AS time_frame,
  ROUND(SUM(total)::numeric) AS sales
FROM cm_orders
GROUP BY time_frame;


--📍 Location Analysis
--Which city performs the best in terms of revenue?

SELECT cm_orders."City", ROUND(SUM(total)::numeric) AS revenue
FROM cm_orders
GROUP BY cm_orders."City"
ORDER BY revenue desc
LIMIT 1;

--What is the average rating given per city?
SELECT cm_orders."City", round(avg(rating)::numeric,2) as avg_rating
FROM cm_orders
GROUP BY cm_orders."City"
ORDER BY avg_rating DESC

--Compare profit margins across branches.
SELECT cm_orders."Branch", round(avg(profit_margin)::numeric,2) as profit_margin
FROM cm_orders
Group by cm_orders."Branch"
ORDER BY profit_margin desc

--What is the sales trend by city over months?

SELECT cm_orders."City", TO_CHAR(TO_DATE(date,'DD-MM-YY'),'MONTH') as Month,
ROUND(SUM(total)::numeric, 2) as total_sales
FROM cm_orders
GROUP BY cm_orders."City",TO_CHAR(TO_DATE(date,'DD-MM-YY'),'MONTH')
ORDER BY total_sales DESC


--💳 Payment & Customer Feedback
-- Which payment method generates the highest revenue?

SELECT payment_method,ROUND(SUM(total)::numeric, 2) as total_sales
FROM cm_orders
group by payment_method
ORDER BY total_sales DESC
LIMIT 1

--Is there a correlation between rating and profit margin?
SELECT CORR(rating::numeric, profit_margin)*100 AS correlation
 FROM cm_orders


--What’s the average rating per payment method?
SELECT payment_method, round(avg(rating)::numeric,2) as avg_rating
FROM cm_orders
group by payment_method


--📆 Time Series & Seasonality
--What is the monthly growth rate in month of december?
WITH monthly_sales AS (
  SELECT 
    TO_CHAR(TO_DATE(date, 'DD-MM-YY'), 'YYYY-MM') AS month,
    SUM(total) AS total_sales
  FROM cm_orders
  GROUP BY TO_CHAR(TO_DATE(date, 'DD-MM-YY'), 'YYYY-MM')
),
december_growth AS (
  SELECT 
    month,
    total_sales,
    LAG(total_sales) OVER (ORDER BY month) AS prev_month_sales
  FROM monthly_sales
  WHERE RIGHT(month, 2) = '11' OR RIGHT(month, 2) = '12'
)
SELECT 
  month,
  total_sales,
  prev_month_sales,
 
    100.0 * (total_sales - prev_month_sales) / NULLIF(prev_month_sales, 0)
   AS growth_rate_percent
FROM december_growth
WHERE RIGHT(month, 2) = '12';


--What are the top sales days of the week?
SELECT 
  TO_CHAR(TO_DATE(date, 'DD-MM-YY'), 'Day') AS day_of_week,
  ROUND(SUM(total)::numeric, 2) AS total_sales
FROM cm_orders
GROUP BY day_of_week
ORDER BY total_sales DESC;
--Which week of the month has the highest sales?
SELECT 
  EXTRACT(WEEK FROM TO_DATE(date, 'DD-MM-YY')) AS week_number,
  ROUND(SUM(total)::numeric, 2) AS total_sales
FROM cm_orders
GROUP BY week_number
ORDER BY total_sales DESC
LIMIT 1;

--Which month had the lowest number of orders?
SELECT 
  TO_CHAR(TO_DATE(date, 'DD-MM-YY'), 'Month') AS month_name,
  COUNT(invoice_id) AS total_orders
FROM cm_orders
GROUP BY month_name
ORDER BY total_orders ASC
LIMIT 1;
