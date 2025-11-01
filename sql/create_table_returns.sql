CREATE DATABASE IF NOT EXISTS sales_dashboard;

USE sales_dashboard;

CREATE TABLE returns (
    return_id VARCHAR(50) PRIMARY KEY,
    sale_id VARCHAR(50),
    article VARCHAR(50),
    return_quantity INTEGER,
    return_amount NUMERIC
);
