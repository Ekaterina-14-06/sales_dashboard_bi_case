USE sales_dashboard;

-- Дашборд для руководителя команды
SELECT 
    t.team_leader_id,
    p.period_month,
    COUNT(DISTINCT t.manager_id) as managers_count,
    SUM(p.plan_revenue) as total_plan_revenue,
    SUM(p.plan_margin) as total_plan_margin,
    COALESCE(SUM(s.sale_amount - COALESCE(r.return_amount, 0)), 0) as total_fact_revenue,
    COALESCE(SUM(ol.line_margin - COALESCE(r.return_amount * (ol.line_margin / NULLIF(ol.line_sum, 0)), 0)), 0) as total_fact_margin
FROM teams t
JOIN plans p ON t.manager_id = p.manager_id
LEFT JOIN orders o ON p.manager_id = o.manager_id AND DATE_FORMAT(o.order_date, '%Y-%m') = p.period_month
LEFT JOIN order_lines ol ON o.order_id = ol.order_id
LEFT JOIN sales s ON o.order_id = s.order_id AND ol.article = s.article  -- связь по order_id И article
LEFT JOIN returns r ON s.sale_id = r.sale_id  -- связь через sale_id
WHERE t.role = 'manager'
GROUP BY t.team_leader_id, p.period_month
ORDER BY t.team_leader_id, p.period_month;