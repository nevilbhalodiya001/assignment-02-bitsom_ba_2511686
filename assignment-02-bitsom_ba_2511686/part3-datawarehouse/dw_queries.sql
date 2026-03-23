-- Q1: Total sales revenue by product category for each month
SELECT
    dd.year,
    dd.month,
    dd.month_name,
    dp.category,
    SUM(fs.total_sales_amount) AS total_revenue,
    SUM(fs.units_sold) AS total_units
FROM fact_sales   fs
JOIN dim_date dd ON fs.date_key = dd.date_key
JOIN dim_product dp ON fs.product_key = dp.product_key
GROUP BY
    dd.year,
    dd.month,
    dd.month_name,
    dp.category
ORDER BY
    dd.year  ASC,
    dd.month ASC,
    total_revenue DESC;


-- Q2: Top 2 performing stores by total revenue
SELECT
    ds.store_key,
    ds.store_name,
    ds.store_city,
    ds.store_zone,
    SUM(fs.total_sales_amount) AS total_revenue,
    SUM(fs.units_sold) AS total_units_sold,
    COUNT(fs.sales_key) AS total_transactions
FROM fact_sales fs
JOIN dim_store ds ON fs.store_key = ds.store_key
GROUP BY
    ds.store_key,
    ds.store_name,
    ds.store_city,
    ds.store_zone
ORDER BY total_revenue DESC
LIMIT 2;


-- Q3: Month-over-month sales trend across all stores
    SELECT
        dd.year,
        dd.month,
        dd.month_name,
        SUM(fs.total_sales_amount) AS monthly_revenue
    FROM fact_sales fs
    JOIN dim_date dd ON fs.date_key = dd.date_key
    GROUP BY
        dd.year,
        dd.month,
        dd.month_name
)
SELECT
    year,
    month,
    month_name,
    monthly_revenue,
    LAG(monthly_revenue) OVER (ORDER BY year, month) AS prev_month_revenue,
    monthly_revenue
        - LAG(monthly_revenue) OVER (ORDER BY year, month) AS mom_change,
    ROUND(
        100.0 * (
            monthly_revenue
            - LAG(monthly_revenue) OVER (ORDER BY year, month)
        ) / NULLIF(
            LAG(monthly_revenue) OVER (ORDER BY year, month), 0
        ),
    2) AS mom_growth_pct
FROM monthly
ORDER BY
    year  ASC,
    month ASC;