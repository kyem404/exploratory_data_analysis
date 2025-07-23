/*
================================================================================
Product Report
================================================================================
Purpose:
	- This report consolidates key product metrics and behaviours.

Highlights:
	1. Gathers essential fields such as product name, category, subcategory, and costs.
	2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
	3. Aggregates product-level metrics:
		- total orders
		- total sales
		- total quantity sold
		- total customers (unique)
		- lifespan (in months)
	4. Calculates valuable KPIs:
		- recency (months since last sale)
		- average order revenue (AOR)
		- average monthly revenue
================================================================================
*/
CREATE VIEW gold.report_products AS 
WITH base_query AS (
SELECT 
	p.product_key,
	p.product_name,
	p.category,
	p.subcategory,
	p.cost,
	f.order_date,
	f.order_number,
	f.sales_amount,
	f.quantity,
	f.customer_key
FROM gold.dim_products p
LEFT JOIN gold.fact_sales f
ON f.product_key = p.product_key)

, product_aggregation AS (
SELECT
	product_key,
	product_name,
	category,
	subcategory,
	SUM(cost) AS total_cost,
	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
	MAX(order_date) AS last_sale_date,
	COUNT(DISTINCT order_number) AS total_orders,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	COUNT(DISTINCT customer_key) AS total_customers
FROM base_query
GROUP BY
	product_key,
	product_name,
	category,
	subcategory
)
SELECT
	product_key,
	product_name,
	category,
	subcategory,
	total_cost,
	total_orders,
	total_sales,
	total_quantity,
	total_customers,
	lifespan,
	DATEDIFF(month, last_sale_date, GETDATE()) AS recency,

	CASE
		 WHEN total_sales > 50000 THEN 'High-Performer'
		 WHEN total_sales >= 10000 THEN 'Mid-Range'
		 ELSE 'Low-Performer'
	END AS product_segment,

	CASE WHEN total_orders = 0 THEN 0
		 ELSE total_sales / total_orders
	END AS avg_product_revenue,

	CASE WHEN lifespan = 0 THEN 0
		 ELSE total_sales / lifespan
	END AS avg_monthly_revenue

FROM product_aggregation;
