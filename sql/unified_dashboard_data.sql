USE sales_dashboard;

SELECT 
    pl.manager_id,
    t.team_leader_id,
    pl.period_month,
    pl.plan_revenue,
    pl.plan_margin,
    COALESCE(SUM(s.sale_amount - COALESCE(r.return_amount, 0)), 0) as fact_revenue,
    COALESCE(SUM(ol.line_margin - COALESCE(r.return_amount * (ol.line_margin / NULLIF(ol.line_sum, 0)), 0)), 0) as fact_margin,
    COUNT(DISTINCT o.client_id) as unique_clients,
    ROUND(COALESCE(SUM(s.sale_amount - COALESCE(r.return_amount, 0)), 0) / NULLIF(COUNT(DISTINCT o.client_id), 0), 2) as avg_client_check,
    pr.category,
    pr.article,
    pr.product_name
FROM plans pl
LEFT JOIN teams t ON pl.manager_id = t.manager_id AND t.role = 'manager'
LEFT JOIN orders o ON pl.manager_id = o.manager_id AND DATE_FORMAT(o.order_date, '%Y-%m') = pl.period_month
LEFT JOIN order_lines ol ON o.order_id = ol.order_id
LEFT JOIN sales s ON o.order_id = s.order_id AND ol.article = s.article
LEFT JOIN returns r ON s.sale_id = r.sale_id
LEFT JOIN products pr ON ol.article = pr.article
GROUP BY pl.manager_id, t.team_leader_id, pl.period_month, pl.plan_revenue, pl.plan_margin, pr.category, pr.article, pr.product_name
ORDER BY pl.manager_id, pl.period_month;