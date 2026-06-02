
-- =============================================
-- Northwind Traders Sales Analysis Project
-- Author: tvoje ime
-- Date: maj 2026
-- Dataset: Northwind Database
-- =============================================


-- =============================================
-- PHASE 1: DATA EXPLORATION
-- =============================================


-- Task 1: Total number of orders

select count(*)
from orders o ;

-- There are 830 orders in the database.

-- Task 2: Time period coverage

select MIN(order_date), 
		MAX(order_date)
		from orders o ;
--The first order date is 04 July 1996 and the last order date is 06 May 1998.

-- Task 3: Total number of customers

select count(*)
from customers c ;
-- There are 91 registered customers in the database.

-- Task 4: Total number of products

select count(*)
from products p ;
--There are also 77 products in the database.

--Task 5: How many products exist per category? Show category name and product count, ordered by count descending.

select c.category_name,
count(p.product_id) as number_of_products
from categories c
join products p on c.category_id = p.category_id
group by c.category_id 
order by number_of_products DESC;
--The product catalog consists of 8 categories. Confections lead with 13 products, while Produce has the fewest with only 5 products.

--Task 6: How many customers do we have per country? Show top 10 countries.

select country,
count(customer_id) as number_of_cumstomers
from customers c 
group by country
order by number_of_cumstomers desc 
limit 10;

-- The USA leads with 13 customers, followed by France and Germany with 11 each, and Brazil with 9. 
-- The top 10 countries are predominantly from Europe and the Americas, reflecting Northwind's core market regions.

--Task 7: How many orders has each employee processed? Show first name, last name and order count, ordered by count descending.

select 	e.first_name, 
		e.last_name,
		count(o.order_id) as order_count
		from employees e 
		join orders o on e.employee_id = o.employee_id
		group by e.employee_id
		order by order_count desc;

--Margaret Peacock leads with 156 processed orders, nearly four times more than the lowest-ranked Steven Buchanan (42). 
--This significant disparity between employees warrants further investigation — potential factors include sick leave, 
--different market assignments, or varying levels of seniority.

-- =============================================
-- PHASE 2: Sales Analysis
-- =============================================


-- Task 9: What is the total revenue per category? Show category name and total revenue, 
-- ordered by revenue descending.

select 	c.category_name,
		SUM(od.unit_price * od.quantity * (1-od.discount)) as total_revenue
		from categories c 
		join products p on p.category_id = c.category_id 
		join order_details od on p.product_id = od.product_id
		group by c.category_name 
		order by total_revenue desc;

-- Despite having the most products, Confections ranks only third in revenue. 
-- Beverages lead with $267,868 in total revenue, followed by Dairy Products with $234,507. 
-- Grains/Cereals generate the least revenue at $95,744.
	

--Task 10: Who are the top 10 customers by total revenue? Show company name and total revenue.

select 	c.company_name,
		SUM(od.unit_price * od.quantity * (1-od.discount)) as total_revenue
		from customers c 
		join orders o on c.customer_id = o.customer_id
		join order_details od on o.order_id = od.order_id
group by c.company_name 
order by total_revenue desc
limit 10;

--QUICK-Stop leads with $110,277 in total revenue, followed closely by Ernst Handel ($104,875) and Save-a-lot Markets ($104,362). 
--There is a significant drop after the top 3 — the fourth-ranked Rattlesnake Canyon Grocery 
--generates less than half the revenue of the leader, 
--suggesting that Northwind's business is heavily dependent on its top 3 customers.

--Task 11: What are the top 10 products by total revenue? Show product name and total revenue.

select 	p.product_name,
		SUM(od.unit_price * od.quantity * (1-od.discount)) as total_revenue
		from products p 
		join order_details od on p.product_id = od.product_id
group by p.product_name 
order by total_revenue desc
limit 10;

--Côte de Blaye dominates product revenue with $141,397 — nearly double the second-ranked Thüringer Rostbratwurst ($80,369). 
--Both are premium European food products, suggesting that high-end specialty items drive the most revenue 
--for Northwind despite likely lower sales volumes.

--Task 12: What is the total revenue per country? Show top 10 countries by revenue.

select c.country,
		SUM(od.unit_price * od.quantity * (1-od.discount)) as total_revenue
		from customers c 
		join orders o on c.customer_id = o.customer_id
		join order_details od on o.order_id = od.order_id
group by c.country  
order by total_revenue desc
limit 10;

--The USA leads with $245,585 in total revenue, followed by Germany ($230,285) and Austria ($128,004). 
--Despite having the most customers, the USA's lead over Germany is relatively small, suggesting German 
--customers place larger individual orders. The top 10 countries are predominantly European, reflecting 
--Northwind's strong presence in the European market.


-- =============================================
-- PHASE 3: Sales Analysis
-- =============================================

--Task 13: What is the total revenue per month? Show year, month and total revenue, ordered chronologically.

select 
		extract (year from o.order_date) as year,
		extract (month from o.order_date) as month,
		SUM(od.unit_price * od.quantity * (1-od.discount)) as total_revenue
		from orders o
		join order_details od on od.order_id = o.order_id
		group by year, month
		order by year, month;


--Revenue shows a clear upward trend over the entire period. Starting at $27,862 in July 1996, monthly revenue 
--grew significantly reaching $104,854 in March 1998. Notable is the sharp drop in May 1998 to $18,334 — however, 
--this is likely due to incomplete data as the dataset ends on May 6, 1998, capturing only the first few days of that month.

--Task 14: What is the total revenue per quarter? Show year, quarter and revenue.

select 
		extract (year from o.order_date) as year,
		extract (quarter from o.order_date) as quarter,
		SUM(od.unit_price * od.quantity * (1-od.discount)) as total_revenue
		from orders o
		join order_details od on od.order_id = o.order_id
		group by year, quarter
		order by year, quarter;
--Revenue shows consistent quarterly growth throughout the entire period. 
--Q1 1998 stands out with $298,492 — more than double Q1 1997 ($138,289), indicating 
--strong year-over-year growth. Q2 1998 appears lower ($142,132) due to incomplete data, 
--as the dataset ends in early May 1998.

--Task 15: What is the monthly revenue growth compared to the previous month? Show year, month, revenue and previous month revenue.


with monthly_revenue as (
		select 
		extract (year from o.order_date) as year,
		extract (month from o.order_date) as month,
		SUM(od.unit_price * od.quantity * (1-od.discount)) as total_revenue
		from orders o
		join order_details od on od.order_id = o.order_id
		group by year, month
		)
		select 	
				year,
				month,
				total_revenue,
				lag(total_revenue) over (order by year,month) as previus_month,
				total_revenue - lag(total_revenue) over (order by year,month) as differce
				from monthly_revenue 
				order by year, month;

--Monthly revenue shows high volatility with significant month-to-month fluctuations. 
--The largest drop occurred in February 1997 (-$22,774) and November 1997 (-$23,215), suggesting seasonal slowdowns. 
--The strongest growth months were January 1997 (+$16,018) and December 1997 (+$27,865), 
--indicating a pattern of strong year-end and new year performance. 
--The May 1998 drop of -$105,465 is due to incomplete data.

-- =============================================
-- PHASE 4: Advanced Analysis
-- =============================================

--Task 16: Rank customers by total revenue — show company name, total revenue and rank.

WITH revenue AS (
    SELECT c.company_name,
        SUM(od.unit_price * od.quantity * (1 - od.discount)) AS total_revenue
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_details od ON od.order_id = o.order_id
    GROUP BY c.company_name
)
SELECT company_name,
    total_revenue,
    DENSE_RANK() OVER (ORDER BY total_revenue DESC) AS rank
FROM revenue;

--All 89 active customers are ranked by total revenue. This ranking enables Pareto analysis — 
--identifying what percentage of total revenue is generated by the top 20% of customers (approximately 18 customers). 
--Combined with previous findings showing QUICK-Stop, Ernst Handel and Save-a-lot Markets generating significantly 
--higher revenue than others, this suggests a classic 80/20 distribution pattern typical in B2B sales.

--Task 17: For each product, show total revenue and its rank within its category — which product is #1 in each category?

WITH product_revenue AS (
    SELECT p.product_name,
        c.category_name,
        SUM(od.unit_price * od.quantity * (1 - od.discount)) AS total_revenue
    FROM products p
    JOIN categories c ON p.category_id = c.category_id
    JOIN order_details od ON p.product_id = od.product_id
    GROUP BY p.product_name, c.category_name
)
SELECT product_name,
    category_name,
    total_revenue,
    DENSE_RANK() OVER (PARTITION BY category_name ORDER BY total_revenue DESC) AS rank
FROM product_revenue;

--Each category has a clear dominant product: Côte de Blaye leads Beverages with $141,397 — 
--far ahead of second-ranked Ipoh Coffee ($23,527). Similarly, Thüringer Rostbratwurst dominates Meat/Poultry 
--with $80,369. This pattern of one dominant product per category is consistent across all 8 categories, 
--suggesting that a small number of premium products drive the majority of revenue within each category.

--Task 18: Show each employee's total revenue and their percentage of total company revenue — who contributes the most?

with employee_revenue as (
select 
		e.last_name,
		e.first_name,
	    SUM(od.unit_price * od.quantity * (1 - od.discount)) AS revenue
	    from employees e 
	    join orders o on e.employee_id = o.employee_id
	    join order_details od on o.order_id = od.order_id
	    group by e.last_name, e.first_name  
	    order by revenue DESC
	)
	select last_name, 
			first_name,
			revenue,
			round(revenue *100.0 / sum(revenue) over()) as percentage
			from employee_revenue;

--Margaret Peacock leads with 18% of total company revenue, followed by Janet Leverling (16%) and Nancy Davolio (15%). 
--The top 3 employees together generate 49% of total revenue — nearly half the company's sales. 
--In contrast, the bottom 3 employees (Dodsworth, Suyama, Buchanan) collectively account for only 17%, 
--suggesting significant performance disparity that warrants further investigation into territory assignments, 
--experience levels, or other contributing factors.

--Task 19: Using CTE, show the top 3 products per category by revenue.

WITH product_revenue AS (
    SELECT p.product_name,
        c.category_name,
        SUM(od.unit_price * od.quantity * (1 - od.discount)) AS total_revenue
    FROM products p
    JOIN categories c ON p.category_id = c.category_id
    JOIN order_details od ON p.product_id = od.product_id
    GROUP BY p.product_name, c.category_name
),
ranked AS (
    SELECT product_name,
        category_name,
        total_revenue,
        DENSE_RANK() OVER (PARTITION BY category_name ORDER BY total_revenue DESC) AS rank
    FROM product_revenue
)
SELECT *
FROM ranked
WHERE rank <= 3
ORDER BY category_name, rank;

--The top 3 products per category reveal clear revenue leaders in each segment. 
--Côte de Blaye dominates Beverages with $141,397, while Thüringer Rostbratwurst leads Meat/Poultry with $80,369. 
--Across all 8 categories, the #1 product consistently generates significantly more revenue than #2 and #3, 
--confirming the pattern of a single dominant product driving category performance.
