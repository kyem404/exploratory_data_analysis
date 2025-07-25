----------------------------------------------------------------
-- Performance Analysis
-- Comparing the current value to a target value.
-- Helps measure success and compare performance.
----------------------------------------------------------------

/* Analyzing the yearly performance of products by comparing each product's sales 
to both its average sales performance and the previous year's sales */

WITH yearly_product_sales AS (
	SELECT
		YEAR(f.order_date) AS order_year,
		p.product_name,
		SUM(f.sales_amount) AS current_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
WHERE order_date IS NOT NULL
GROUP BY
	YEAR(f.order_date),
	p.product_name
)

	SELECT
		order_year,
		product_name,
		current_sales,
		AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,
		current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,
		CASE WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
			 WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'
			 ELSE 'Avg'
		END avg_change,
		LAG (current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS py_sales,
		current_sales - LAG (current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_py,
		CASE WHEN current_sales - LAG (current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
			 WHEN current_sales - LAG (current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
			 ELSE 'No change'
		END py_change
FROM yearly_product_sales
ORDER BY product_name, order_year;


/* Analyzing the monthly performance of products by comparing each product's sales 
to both its average sales performance and the previous month's sales */

WITH yearly_product_sales AS (
	SELECT
		MONTH(f.order_date) AS order_year,
		p.product_name,
		SUM(f.sales_amount) AS current_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
WHERE order_date IS NOT NULL
GROUP BY
	MONTH(f.order_date),
	p.product_name
)

	SELECT
		order_year,
		product_name,
		current_sales,
		AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,
		current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,
		CASE WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
			 WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'
			 ELSE 'Avg'
		END avg_change,
		LAG (current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS py_sales,
		current_sales - LAG (current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_py,
		CASE WHEN current_sales - LAG (current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
			 WHEN current_sales - LAG (current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
			 ELSE 'No change'
		END py_change
FROM yearly_product_sales
ORDER BY product_name, order_year;
