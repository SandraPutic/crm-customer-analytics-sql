-- =====================================
-- CRM CUSTOMER ANALYTICS PROJECT
-- =====================================

-- 1. Active users (last 30 days)
SELECT COUNT(DISTINCT customer_id) AS active_users
FROM orders
WHERE order_date >= CURRENT_DATE - INTERVAL '30 days';

-- 2. Churned users (no orders in last 60 days)
SELECT customer_id
FROM customers
WHERE customer_id NOT IN (
    SELECT DISTINCT customer_id
    FROM orders
    WHERE order_date >= CURRENT_DATE - INTERVAL '60 days'
);

-- 3. Repeat customers (Retention)
SELECT 
    COUNT(*) AS repeat_customers
FROM (
    SELECT customer_id
    FROM orders
    GROUP BY customer_id
    HAVING COUNT(order_id) > 1
) t;

-- 4. ARPU (Average Revenue Per User)
SELECT 
    SUM(amount) / COUNT(DISTINCT customer_id) AS arpu
FROM orders;

-- 5. Customer segmentation
SELECT 
    customer_id,
    COUNT(order_id) AS orders_count,
    SUM(amount) AS total_spent,
    CASE 
        WHEN SUM(amount) > 1000 THEN 'VIP'
        WHEN SUM(amount) > 500 THEN 'Middle'
        ELSE 'Low'
    END AS segment
FROM orders
GROUP BY customer_id;

-- 6. Average days between orders (window function)
SELECT 
    customer_id,
    AVG(order_date - LAG(order_date) OVER (
        PARTITION BY customer_id 
        ORDER BY order_date
    )) AS avg_days_between_orders
FROM orders
GROUP BY customer_id;

-- 7. RFM Analysis
WITH rfm AS (
    SELECT 
        customer_id,
        MAX(order_date) AS last_order,
        COUNT(order_id) AS frequency,
        SUM(amount) AS monetary
    FROM orders
    GROUP BY customer_id
)
SELECT 
    customer_id,
    CURRENT_DATE - last_order AS recency_days,
    frequency,
    monetary
FROM rfm;

-- 8. Advanced: ranking customers by spending
WITH customer_stats AS (
    SELECT 
        customer_id,
        COUNT(*) AS orders_count,
        SUM(amount) AS total_spent,
        MAX(order_date) AS last_order
    FROM orders
    GROUP BY customer_id
)
SELECT 
    *,
    RANK() OVER (ORDER BY total_spent DESC) AS spending_rank
FROM customer_stats;
