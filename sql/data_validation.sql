USE sales_dashboard;

-- =============================================
-- ПРОВЕРКА ДАННЫХ ДЛЯ ДАШБОРДОВ
-- =============================================

-- Проверка планов и фактов по менеджерам
SELECT 
    p.manager_id,
    p.period_month,
    p.plan_revenue,
    COALESCE(SUM(s.sale_amount - COALESCE(r.return_amount, 0)), 0) as fact_revenue,
    CASE 
        WHEN p.plan_revenue > 0 THEN ROUND(COALESCE(SUM(s.sale_amount - COALESCE(r.return_amount, 0)), 0) / p.plan_revenue * 100, 2)
        ELSE 0 
    END as achievement_percent
FROM plans p
LEFT JOIN orders o ON p.manager_id = o.manager_id AND DATE_FORMAT(o.order_date, '%Y-%m') = p.period_month
LEFT JOIN sales s ON o.order_id = s.order_id
LEFT JOIN returns r ON s.sale_id = r.sale_id
GROUP BY p.manager_id, p.period_month, p.plan_revenue
ORDER BY achievement_percent DESC;

-- Проверка связей между таблицами
SELECT 
    'orders without clients' as issue, COUNT(*) as count 
FROM orders o LEFT JOIN clients c ON o.client_id = c.client_id 
WHERE c.client_id IS NULL
UNION ALL
SELECT 'order_lines without products', COUNT(*) 
FROM order_lines ol LEFT JOIN products p ON ol.article = p.article 
WHERE p.article IS NULL
UNION ALL
SELECT 'sales without orders', COUNT(*) 
FROM sales s LEFT JOIN orders o ON s.order_id = o.order_id 
WHERE o.order_id IS NULL;