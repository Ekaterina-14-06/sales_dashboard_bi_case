CREATE DATABASE IF NOT EXISTS sales_dashboard;

USE sales_dashboard;

CREATE TABLE sales (
    sale_id VARCHAR(50) PRIMARY KEY,
    order_id VARCHAR(50),
    article VARCHAR(50),
    quantity INTEGER,
    sale_amount NUMERIC
);
