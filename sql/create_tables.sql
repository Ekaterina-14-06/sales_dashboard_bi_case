-- SQL скрипт для создания базы данных и таблиц
-- В DBEAVER (русская версия): выделить ВЕСЬ текст и выполнить через Редактор SQL -> Выполнить SQL-скрипт (Alt+X)

-- Создание базы данных
CREATE DATABASE IF NOT EXISTS sales_dashboard;

-- Использование базы данных
USE sales_dashboard;

-- Создание таблиц
-- Таблица: products
CREATE TABLE products (
    article VARCHAR(50) PRIMARY KEY,
    product_name VARCHAR(255),
    category VARCHAR(100),
    cost INTEGER
);

-- Таблица: clients
CREATE TABLE clients (
    client_id VARCHAR(50) PRIMARY KEY,
    client_name VARCHAR(255),
    inn VARCHAR(50),
    manager_id VARCHAR(50)
);

-- Таблица: teams
CREATE TABLE teams (
    manager_id VARCHAR(50),
    team_leader_id VARCHAR(50),
    role VARCHAR(50)
);

-- Таблица: orders
CREATE TABLE orders (
    order_id VARCHAR(50) PRIMARY KEY,
    client_id VARCHAR(50),
    order_date DATE,
    order_total NUMERIC,
    manager_id VARCHAR(50)
);

-- Таблица: order_lines
CREATE TABLE order_lines (
    order_line_id VARCHAR(50) PRIMARY KEY,
    order_id VARCHAR(50),
    article VARCHAR(50),
    quantity INTEGER,
    price NUMERIC,
    line_sum NUMERIC,
    line_margin NUMERIC
);

-- Таблица: sales
CREATE TABLE sales (
    sale_id VARCHAR(50) PRIMARY KEY,
    order_id VARCHAR(50),
    article VARCHAR(50),
    quantity INTEGER,
    sale_amount NUMERIC
);

-- Таблица: returns
CREATE TABLE returns (
    return_id VARCHAR(50) PRIMARY KEY,
    sale_id VARCHAR(50),
    article VARCHAR(50),
    return_quantity INTEGER,
    return_amount NUMERIC
);

-- Таблица: plans
CREATE TABLE plans (
    manager_id VARCHAR(50),
    period_month VARCHAR(10),
    plan_revenue NUMERIC,
    plan_margin NUMERIC
);

-- Скрипт завершен. Теперь можно импортировать CSV файлы из папки data_sample/
