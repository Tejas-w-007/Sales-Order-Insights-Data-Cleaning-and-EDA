-- Creating orders table with specific data types for efficient working
CREATE TABLE df_orders (
    order_id INT PRIMARY KEY,
    order_date DATE,
    ship_mode VARCHAR(20),
    segment VARCHAR(20),
    country VARCHAR(20),
    city VARCHAR(20),
    state VARCHAR(20),
    postal_code VARCHAR(20),
    region VARCHAR(20),
    category VARCHAR(20),
    sub_category VARCHAR(20),
    product_id VARCHAR(50),
    quantity INT,
    discount DECIMAL(7,2),
    sale_price DECIMAL(7,2),
    profit DECIMAL(7,2)
);

-- Checking the dataset which has 9994 rows
select * from orders
select count(*) from orders
--Data Analysis
-- Find top 10 highest revenue generating products
select 
	sub_category as Products, 
	sum(sale_price) as Sales 
from orders
group by 1
order by 2 desc
Limit 10 ; 

--top 5 highest selling products in each region
with cte as (
select 
	region,
	sub_category as Products, 
	sum(sale_price) as Sales 
from orders
group by 1, 2
order by 1, 3 desc)
select * from(
select * ,
	rank() over(partition by region order by Sales desc) as rn
from cte) A where rn <= 5

--Find growth comparison between 2022 and 2023 in terms of months e.g. Jan 2022 vs Jan 2023
with cte as (
select
	extract(year from order_date) as order_year, extract(month from order_date) as order_month, sum(sale_price) as sales
from orders
group by 1, 2
order by 1, 2)
select order_month,
	sum(case when order_year= 2022 then sales else 0 end) as sales_2022,
	sum(case when order_year= 2023 then sales else 0 end) as sales_2023
from cte
group by 1
order by 1
	
--for each category finding the highest sales month
with cte as (
SELECT 
    category, 
    TO_CHAR(order_date, 'mm-yyyy') AS order_month_year, 
    SUM(sale_price) AS sales 
FROM orders
GROUP BY 1, 2
ORDER BY 1, 2 
)
select * from (
select *,
	rank() over(partition by category order by sales desc) as rn
from cte
) where rn = 1

--which sub category has the highest growth percentage compared to last year
with cte as (
select
	sub_category,
	extract(year from order_date) as order_year, 
	sum(sale_price) as sales
from orders
group by 1,2
order by 1,2)
, cte2 as (
select sub_category,
	sum(case when order_year= 2022 then sales else 0 end) as sales_2022,
	sum(case when order_year= 2023 then sales else 0 end) as sales_2023
from cte
group by 1
order by 1
)
select *,
	(sales_2023 - sales_2022)*100/sales_2022 as growth_percent
from cte2
order by growth_percent desc
limit 1;

