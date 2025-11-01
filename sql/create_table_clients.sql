CREATE DATABASE IF NOT EXISTS sales_dashboard;

USE sales_dashboard;

CREATE TABLE clients (
    client_id VARCHAR(50) PRIMARY KEY,
    client_name VARCHAR(255),
    inn VARCHAR(50),
    manager_id VARCHAR(50)
);
