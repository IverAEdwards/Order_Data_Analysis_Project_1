-- top 10 items by sales

SELECT product_id, sum(sale_price) as sales

FROM `totemic-web-426306-i7.my_dataset.orders_cleaned`

GROUP BY product_id
ORDER BY sales DESC
LIMIT 10;

-- top 5 items per region

SELECT
  region,product_id, sales
FROM (
  SELECT
    region,
    product_id,
    SUM(sale_price) AS sales,
    RANK() OVER (PARTITION BY region ORDER BY SUM(sale_price) DESC) AS sales_rank
  FROM
    `totemic-web-426306-i7.my_dataset.orders_cleaned`
  GROUP BY
    region, product_id
) AS ranked_sales
WHERE
  sales_rank <= 5
ORDER BY
  region,
  sales DESC;

-- month on month growth comparison
WITH cte AS(
SELECT 
EXTRACT(YEAR FROM order_date) AS year,
EXTRACT(MONTH FROM order_date) AS month,
sum(sale_price) AS sales

FROM `totemic-web-426306-i7.my_dataset.orders_cleaned`

GROUP BY year, month
)
SELECT month,
SUM(CASE WHEN year = 2022 THEN sales ELSE 0 END) AS sales_2022,
SUM(CASE WHEN year = 2023 THEN sales ELSE 0 END) AS sales_2023

from cte
GROUP BY month
ORDER BY month;

-- for each category which month had the highest sales
WITH cte AS(
SELECT category, FORMAT_TIMESTAMP('%y%m', order_date) AS order_year_month, sum(sale_price) AS sales

FROM `totemic-web-426306-i7.my_dataset.orders_cleaned`

GROUP BY category, order_year_month)
SELECT * FROM(
SELECT *, row_number() OVER(PARTITION BY category ORDER BY sales DESC) as rn
FROM cte
) a
WHERE rn=1;

-- which sub catergory ordered by highest growth percentaeg by 2023 compared to 2022

WITH cte AS(
SELECT
sub_category,
EXTRACT(YEAR FROM order_date) AS year,
sum(sale_price) AS sales

FROM `totemic-web-426306-i7.my_dataset.orders_cleaned`

GROUP BY sub_category,year)
,cte2 as(
SELECT sub_category,
SUM(CASE WHEN year = 2022 THEN sales ELSE 0 END) AS sales_2022,
SUM(CASE WHEN year = 2023 THEN sales ELSE 0 END) AS sales_2023

FROM cte
GROUP BY sub_category)
SELECT *, (sales_2023-sales_2022)*100/sales_2022 AS percent_increase
FROM cte2
ORDER BY percent_increase DESC