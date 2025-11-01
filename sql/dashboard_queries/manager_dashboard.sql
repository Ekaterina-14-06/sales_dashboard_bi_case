USE sales_dashboard;

-- Дашборд для менеджера
SELECT 
    p.manager_id,
    p.period_month,
    p.plan_revenue,
    p.plan_margin,
    COALESCE(SUM(s.sale_amount - COALESCE(r.return_amount, 0)), 0) as fact_revenue,
    COALESCE(SUM(ol.line_margin - COALESCE(r.return_amount * (ol.line_margin / NULLIF(ol.line_sum, 0)), 0)), 0) as fact_margin,
    COUNT(DISTINCT o.client_id) as unique_clients,
    ROUND(COALESCE(SUM(s.sale_amount - COALESCE(r.return_amount, 0)), 0) / NULLIF(COUNT(DISTINCT o.client_id), 0), 2) as avg_client_check
FROM plans p
LEFT JOIN orders o ON p.manager_id = o.manager_id AND DATE_FORMAT(o.order_date, '%Y-%m') = p.period_month
LEFT JOIN order_lines ol ON o.order_id = ol.order_id
LEFT JOIN sales s ON o.order_id = s.order_id AND ol.article = s.article
LEFT JOIN returns r ON s.sale_id = r.sale_id
GROUP BY p.manager_id, p.period_month, p.plan_revenue, p.plan_margin
ORDER BY p.manager_id, p.period_month;