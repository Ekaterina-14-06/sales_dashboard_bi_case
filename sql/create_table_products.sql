CREATE DATABASE IF NOT EXISTS sales_dashboard;

USE sales_dashboard;

CREATE TABLE products (
    article VARCHAR(50) PRIMARY KEY,
    product_name VARCHAR(255),
    category VARCHAR(100),
    cost INTEGER
);
