-- Change database to Atliq Hardwares
USE gdb023;

-- 1. The list of markets in which the customer "Atliq Exclusive" operates its business in the APAC region

SELECT
		DISTINCT market
FROM
		dim_customer
WHERE
		customer = "Atliq Exclusive" AND
        region = "APAC";
        
---------------------------------------------------------------------------------------------------------------------------------------
-- 2. What is the percentage of unique product increase in 2021 vs. 2020?

 WITH FY20 AS (
				SELECT
					COUNT(DISTINCT(product_code)) AS up_20	
				FROM
					fact_sales_monthly
				WHERE
					fiscal_year = 2020
), FY21 AS (
				SELECT
					COUNT(DISTINCT(product_code)) AS up_21	
				FROM
					fact_sales_monthly
				WHERE
					fiscal_year = 2021
)
SELECT
	FY20.up_20 AS unique_product_2020,
    FY21.up_21 AS unique_product_2021,
    CONCAT(ROUND((FY21.up_21 - FY20.up_20) * 100/FY20.up_20, 2), '%')AS percentage_chg
FROM
	FY20, FY21;
    
---------------------------------------------------------------------------------------------------------------------------------------
-- 3. Provide a report with all the unique product counts for each segment and sort them in descending order of product counts.

SELECT
	segment,
    COUNT(product) AS product_count
FROM
	dim_product
GROUP BY
	segment
ORDER  BY
	product_count DESC;
        
---------------------------------------------------------------------------------------------------------------------------------------
-- 4. Follow-up: Which segment had the most increase in unique products in 2021 vs 2020?

WITH FY20 AS (
				SELECT
					segment,
                    COUNT(DISTINCT(s.product_code)) AS seg20
				FROM
					fact_sales_monthly s
				JOIN
					dim_product p
				ON
					s.product_code = p.product_code
				WHERE
					fiscal_year = 2020
				GROUP BY
					p.segment
), FY21 AS (
				SELECT
					segment,
                    COUNT(DISTINCT(s.product_code)) AS seg21
				FROM
					fact_sales_monthly s
				JOIN
					dim_product p
				ON
					s.product_code = p.product_code
				WHERE
					fiscal_year = 2021
				GROUP BY
					p.segment
)
SELECT
	FY20.segment, 
    seg20 AS product_count_2020,
    seg21 AS product_count_2021,
    seg21 - seg20 AS difference
FROM
	FY20
JOIN
	FY21
ON
	FY20.segment = FY21.segment
ORDER BY
	difference DESC;
---------------------------------------------------------------------------------------------------------------------------------------
-- 5. Get the products that have the highest and lowest manufacturing costs.    

SELECT
	c.product_code,
    product,
    CONCAT(manufacturing_cost, '/unit') AS manufacturing_cost
FROM
	fact_manufacturing_cost AS c
JOIN
	dim_product p
ON
	p.product_code = c.product_code
WHERE
	c.manufacturing_cost = (
									SELECT
										MAX(manufacturing_cost)
									FROM
										fact_manufacturing_cost
									) OR
	c.manufacturing_cost = (
									SELECT
										MIN(manufacturing_cost)
									FROM
										fact_manufacturing_cost
									)
ORDER BY
	manufacturing_cost DESC;
    
---------------------------------------------------------------------------------------------------------------------------------------
-- 6. Generate a report which contains the top 5 customers who received an average high pre_invoice_discount_pct for the fiscal year 2021 and in the Indian market.
SELECT
	d.customer_code,
    customer,
    ROUND(AVG(pre_invoice_discount_pct) * 100, 2) AS average_discount_percentage
FROM
	fact_pre_invoice_deductions d
JOIN
	dim_customer c
ON
	d.customer_code = c.customer_code
WHERE
	market = "India" AND
    d.fiscal_year = 2021
GROUP BY
	customer,
    d.customer_code
ORDER BY
	average_discount_percentage DESC
LIMIT
	5;
    
---------------------------------------------------------------------------------------------------------------------------------------
-- 7. Get the complete report of the Gross sales amount for the customer “Atliq Exclusive” for each month. This analysis helps to get an idea of low and high-performing months and take strategic decisions.

WITH gross_sales_table AS (
						SELECT
							date,
							s.customer_code,
							p.fiscal_year,
							gross_price * sold_quantity AS gross_sales
						FROM
							fact_gross_price p
						JOIN
							fact_sales_monthly s
						ON
							s.product_code = p.product_code AND
							s.fiscal_year = p.fiscal_year
), customer_sort AS (
						SELECT
							date,
                            c.customer_code,
                            gross_sales
						FROM
							gross_sales_table t
						JOIN
							dim_customer c
						ON
							t.customer_code = c.customer_code
						WHERE
							customer = "Atliq Exclusive"
)
SELECT
	MONTH(date) AS month,
    YEAR(date) AS year,
    ROUND(SUM(gross_sales) / 1000000, 2) AS gross_sales_amount_mln
FROM
	customer_sort
GROUP BY
	month, year;
    
---------------------------------------------------------------------------------------------------------------------------------------
-- 8. In which quarter of 2020 got the maximum total_sold_quantity?

WITH quarter AS (
				SELECT
					sold_quantity,
                    CASE
						WHEN
							MONTH(date) BETWEEN 09 AND 11
						THEN
							"Q1"
						WHEN
							MONTH(date) IN (12, 01, 02)
						THEN
							"Q2"
						WHEN
							MONTH(date) BETWEEN 03 AND 05
						THEN
							"Q3"
						WHEN
							MONTH(date) BETWEEN 06 AND 08
						THEN
							"Q4"
					END AS Quarter
				FROM
					fact_sales_monthly
				WHERE
					fiscal_year = 2020
)
SELECT
	Quarter,
    SUM(sold_quantity) AS total_sold_quantity
FROM
	quarter
GROUP BY
	Quarter
ORDER BY
	total_sold_quantity DESC;
    
---------------------------------------------------------------------------------------------------------------------------------------
-- 9. Which channel helped to bring more gross sales in the fiscal year 2021 and the percentage of contribution?
    
WITH gross_sale_table AS (
				SELECT
					customer_code,
					gross_price *sold_quantity AS gross_sales_mln
				FROM
					fact_gross_price g
				JOIN
					fact_sales_monthly s
				ON
					g.product_code = s.product_code AND
					g.fiscal_year = s.fiscal_year
				WHERE
					g.fiscal_year = 2021
), channel_table AS (
				SELECT
					channel,
					ROUND(SUM(gross_sales_mln / 1000000), 3) AS gross_sales_mln
				FROM
					gross_sale_table gt
				JOIN
					dim_customer c
				ON
					c.customer_code = gt.customer_code
				GROUP BY
					channel
), total_sum AS (
				SELECT
					SUM(gross_sales_mln) AS SUM_
				FROM
					channel_table
)
SELECT
	ct.*,
    CONCAT(ROUND(ct.gross_sales_mln * 100 / ts.SUM_, 2), '%') AS percentage
FROM
	channel_table ct, total_sum ts
ORDER BY
	percentage DESC;
    
    
---------------------------------------------------------------------------------------------------------------------------------------

-- 10. Get the Top 3 products in each division that have a high total_sold_quantity in the fiscal_year 2021?
    
WITH product_table AS (
					SELECT
						p.division,
                        s.product_code,
                        p.product,
                        SUM(s.sold_quantity) AS total_sold_quantity
					FROM
						fact_sales_monthly s
					JOIN
						dim_product p
					ON
						p.product_code = s.product_code
					WHERE
						s.fiscal_year  = 2021
					GROUP BY
						s.product_code,
                        p.division,
                        p.product
), rank_table AS (
					SELECT
						*,
                        RANK() OVER(PARTITION BY division ORDER BY total_sold_quantity DESC) AS rank_order
					FROM
						product_table
)
SELECT
	*
FROM
	rank_table
WHERE
	rank_order < 4;
