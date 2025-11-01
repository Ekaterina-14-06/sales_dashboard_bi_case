USE sales_dashboard;

-- Проверка данных после импорта
SELECT 'products' as table_name, COUNT(*) as count FROM products
UNION ALL SELECT 'clients', COUNT(*) FROM clients
UNION ALL SELECT 'teams', COUNT(*) FROM teams
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'order_lines', COUNT(*) FROM order_lines
UNION ALL SELECT 'sales', COUNT(*) FROM sales
UNION ALL SELECT 'returns', COUNT(*) FROM returns
UNION ALL SELECT 'plans', COUNT(*) FROM plans;