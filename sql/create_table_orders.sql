CREATE DATABASE IF NOT EXISTS sales_dashboard;

USE sales_dashboard;

CREATE TABLE orders (
    order_id VARCHAR(50) PRIMARY KEY,
    client_id VARCHAR(50),
    order_date DATE,
    order_total NUMERIC,
    manager_id VARCHAR(50)
);
