--View 1: Total Revenue 

create view total_revenue as 
select 
		SUM(od.unit_price * od.quantity * (1-od.discount)) as total_revenue
		from order_details od;

--View 2: Revenue by Category

create view revenue_by_category as
select 	c.category_name,
		SUM(od.unit_price * od.quantity * (1-od.discount)) as total_revenue
		from categories c 
		join products p on p.category_id = c.category_id 
		join order_details od on p.product_id = od.product_id
		group by c.category_name 
		order by total_revenue desc;

--View 3: Top 10 Customers

create view top_10_customers as 
select 	c.company_name,
		SUM(od.unit_price * od.quantity * (1-od.discount)) as total_revenue
		from customers c 
		join orders o on c.customer_id = o.customer_id
		join order_details od on o.order_id = od.order_id
group by c.company_name 
order by total_revenue desc
limit 10;

--View 4: Monthly Revenue Trend

CREATE OR REPLACE VIEW monthly_revenue_trend AS
SELECT 
    EXTRACT(YEAR FROM o.order_date) AS year,
    EXTRACT(MONTH FROM o.order_date) AS month,
    TO_DATE(EXTRACT(YEAR FROM o.order_date)::text || '-' || 
            EXTRACT(MONTH FROM o.order_date)::text || '-01', 'YYYY-MM-DD') AS period,
    SUM(od.unit_price * od.quantity * (1 - od.discount)) AS total_revenue
FROM orders o
JOIN order_details od ON od.order_id = o.order_id
GROUP BY year, month
ORDER BY year, month;

--View 5: Revenue by Country

create view revenue_by_country as 
select c.country,
		SUM(od.unit_price * od.quantity * (1-od.discount)) as total_revenue
		from customers c 
		join orders o on c.customer_id = o.customer_id
		join order_details od on o.order_id = od.order_id
group by c.country  
order by total_revenue desc
limit 10;

--View 6: Revenue by Employee

create view revenue_by_employee AS
WITH employee_revenue AS (
    SELECT
        e.first_name || ' ' || e.last_name AS employee_name,
        SUM(od.unit_price * od.quantity * (1 - od.discount)) AS revenue
    FROM employees e
    JOIN orders o ON e.employee_id = o.employee_id
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY e.first_name, e.last_name
)
SELECT employee_name,
    revenue,
    ROUND((revenue * 100.0 / SUM(revenue) OVER())::numeric, 2) AS percentage
FROM employee_revenue
ORDER BY revenue DESC;


--
SELECT * FROM monthly_revenue_trend LIMIT 3;

--
SELECT * FROM revenue_by_employee LIMIT 3;

SELECT column_name 
FROM information_schema.columns 
WHERE table_name = 'revenue_by_employee';