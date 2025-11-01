CREATE DATABASE IF NOT EXISTS sales_dashboard;

USE sales_dashboard;

CREATE TABLE plans (
    manager_id VARCHAR(50),
    period_month VARCHAR(10),
    plan_revenue NUMERIC,
    plan_margin NUMERIC
);
