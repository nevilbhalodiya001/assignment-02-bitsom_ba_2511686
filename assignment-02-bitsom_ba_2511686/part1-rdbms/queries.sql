-- Q1: List all customers from Mumbai along with their total order value
SELECT
    c.customer_id,
    c.customer_name,
    c.customer_city,
    SUM(oi.quantity * oi.unit_price) AS total_order_value
FROM Customers c
JOIN Orders o ON c.customer_id  = o.customer_id
JOIN OrderItems oi ON o.order_id = oi.order_id
WHERE c.customer_city = 'Mumbai'
GROUP BY c.customer_id, c.customer_name, c.customer_city
ORDER BY total_order_value DESC;

-- Q2: Find the top 3 products by total quantity sold
SELECT
    p.product_id,
    p.product_name,
    p.category,
    SUM(oi.quantity) AS total_quantity_sold
FROM Products p
JOIN OrderItems oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name, p.category
ORDER BY total_quantity_sold DESC
LIMIT 3;

-- Q3: List all sales representatives and the number of unique customers they have handled
SELECT
    sr.sales_rep_id,
    sr.sales_rep_name,
    sr.sales_rep_email,
    COUNT(DISTINCT o.customer_id) AS unique_customers_handled
FROM SalesReps sr
LEFT JOIN Orders o ON sr.sales_rep_id = o.sales_rep_id
GROUP BY sr.sales_rep_id, sr.sales_rep_name, sr.sales_rep_email
ORDER BY unique_customers_handled DESC;

-- Q4: Find all orders where the total value exceeds 10,000, sorted by value descending
SELECT
    o.order_id,
    c.customer_name,
    c.customer_city,
    sr.sales_rep_name,
    o.order_date,
    SUM(oi.quantity * oi.unit_price) AS total_order_value
FROM Orders o
JOIN Customers  c  ON o.customer_id  = c.customer_id
JOIN SalesReps  sr ON o.sales_rep_id = sr.sales_rep_id
JOIN OrderItems oi ON o.order_id = oi.order_id
GROUP BY o.order_id, c.customer_name, c.customer_city, sr.sales_rep_name, o.order_date
HAVING SUM(oi.quantity * oi.unit_price) > 10000
ORDER BY total_order_value DESC;

-- Q5: Identify any products that have never been ordered
SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.unit_price
FROM Products p
LEFT JOIN OrderItems oi ON p.product_id = oi.product_id
WHERE oi.product_id IS NULL
ORDER BY p.product_id;