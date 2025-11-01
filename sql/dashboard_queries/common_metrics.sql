USE sales_dashboard;

-- =============================================
-- ОБЩИЕ МЕТРИКИ ДЛЯ ДАШБОРДОВ
-- Автор: Екатерина
-- Проект: Sales Dashboard BI Case
-- =============================================

-- 1. ВЫРУЧКА ПО КАТЕГОРИЯМ ТОВАРОВ
SELECT 
    p.category,
    DATE_FORMAT(o.order_date, '%Y-%m') as period_month,
    SUM(s.sale_amount - COALESCE(r.return_amount, 0)) as revenue,
    COUNT(DISTINCT o.order_id) as order_count,
    ROUND(SUM(s.sale_amount - COALESCE(r.return_amount, 0)) / COUNT(DISTINCT o.order_id), 2) as avg_order_value
FROM products p
JOIN order_lines ol ON p.article = ol.article
JOIN orders o ON ol.order_id = o.order_id
JOIN sales s ON o.order_id = s.order_id AND ol.article = s.article
LEFT JOIN returns r ON s.sale_id = r.sale_id
GROUP BY p.category, DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY period_month, revenue DESC;

-- 2. ТОП-10 АРТИКУЛОВ ПО ВЫРУЧКЕ
SELECT 
    p.article,
    p.product_name,
    p.category,
    DATE_FORMAT(o.order_date, '%Y-%m') as period_month,
    SUM(s.quantity - COALESCE(r.return_quantity, 0)) as sold_quantity,
    SUM(s.sale_amount - COALESCE(r.return_amount, 0)) as revenue,
    ROUND(SUM(s.sale_amount - COALESCE(r.return_amount, 0)) / SUM(s.quantity - COALESCE(r.return_quantity, 0)), 2) as avg_price
FROM products p
JOIN order_lines ol ON p.article = ol.article
JOIN orders o ON ol.order_id = o.order_id
JOIN sales s ON o.order_id = s.order_id AND ol.article = s.article
LEFT JOIN returns r ON s.sale_id = r.sale_id
GROUP BY p.article, p.product_name, p.category, DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY revenue DESC
LIMIT 10;

-- 3. ДИНАМИКА ВЫРУЧКИ ПО МЕСЯЦАМ
SELECT 
    DATE_FORMAT(o.order_date, '%Y-%m') as period_month,
    SUM(s.sale_amount - COALESCE(r.return_amount, 0)) as total_revenue,
    SUM(ol.line_margin - COALESCE(r.return_amount * (ol.line_margin / NULLIF(ol.line_sum, 0)), 0)) as total_margin,
    COUNT(DISTINCT o.order_id) as total_orders,
    COUNT(DISTINCT o.client_id) as unique_clients
FROM orders o
JOIN order_lines ol ON o.order_id = ol.order_id
JOIN sales s ON o.order_id = s.order_id AND ol.article = s.article
LEFT JOIN returns r ON s.sale_id = r.sale_id
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY period_month;

-- 4. КЛИЕНТЫ С НАИБОЛЬШИМ СРЕДНИМ ЧЕКОМ
SELECT 
    c.client_id,
    c.client_name,
    c.manager_id,
    COUNT(DISTINCT o.order_id) as order_count,
    SUM(s.sale_amount - COALESCE(r.return_amount, 0)) as total_revenue,
    ROUND(SUM(s.sale_amount - COALESCE(r.return_amount, 0)) / COUNT(DISTINCT o.order_id), 2) as avg_check
FROM clients c
JOIN orders o ON c.client_id = o.client_id
JOIN order_lines ol ON o.order_id = ol.order_id
JOIN sales s ON o.order_id = s.order_id AND ol.article = s.article
LEFT JOIN returns r ON s.sale_id = r.sale_id
GROUP BY c.client_id, c.client_name, c.manager_id
HAVING order_count >= 2
ORDER BY avg_check DESC
LIMIT 15;

-- 5. УРОВЕНЬ ВОЗВРАТОВ ПО КАТЕГОРИЯМ
SELECT 
    p.category,
    DATE_FORMAT(o.order_date, '%Y-%m') as period_month,
    SUM(s.sale_amount) as total_sales,
    SUM(COALESCE(r.return_amount, 0)) as total_returns,
    ROUND(SUM(COALESCE(r.return_amount, 0)) / SUM(s.sale_amount) * 100, 2) as return_rate_percent
FROM products p
JOIN order_lines ol ON p.article = ol.article
JOIN orders o ON ol.order_id = o.order_id
JOIN sales s ON o.order_id = s.order_id AND ol.article = s.article
LEFT JOIN returns r ON s.sale_id = r.sale_id
GROUP BY p.category, DATE_FORMAT(o.order_date, '%Y-%m')
HAVING total_sales > 0
ORDER BY period_month, return_rate_percent DESC;

-- 6. ВЫРУЧКА ПО КАТЕГОРИЯМ С ФИЛЬТРОМ ПО МЕНЕДЖЕРУ
SELECT 
    p.category,
    o.manager_id,
    DATE_FORMAT(o.order_date, '%Y-%m') as period_month,
    SUM(s.sale_amount - COALESCE(r.return_amount, 0)) as revenue
FROM products p
JOIN order_lines ol ON p.article = ol.article
JOIN orders o ON ol.order_id = o.order_id
JOIN sales s ON o.order_id = s.order_id AND ol.article = s.article
LEFT JOIN returns r ON s.sale_id = r.sale_id
GROUP BY p.category, o.manager_id, DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY period_month, revenue DESC;

-- 7. ВЫРУЧКА ПО АРТИКУЛАМ С ФИЛЬТРАЦИЕЙ
SELECT 
    p.article,
    p.product_name,
    p.category,
    o.manager_id,
    DATE_FORMAT(o.order_date, '%Y-%m') as period_month,
    SUM(s.sale_amount - COALESCE(r.return_amount, 0)) as revenue
FROM products p
JOIN order_lines ol ON p.article = ol.article
JOIN orders o ON ol.order_id = o.order_id
JOIN sales s ON o.order_id = s.order_id AND ol.article = s.article
LEFT JOIN returns r ON s.sale_id = r.sale_id
GROUP BY p.article, p.product_name, p.category, o.manager_id, DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY revenue DESC;