CREATE DATABASE IF NOT EXISTS sales_dashboard;

USE sales_dashboard;

CREATE TABLE order_lines (
    order_line_id VARCHAR(50) PRIMARY KEY,
    order_id VARCHAR(50),
    article VARCHAR(50),
    quantity INTEGER,
    price NUMERIC,
    line_sum NUMERIC,
    line_margin NUMERIC
);
