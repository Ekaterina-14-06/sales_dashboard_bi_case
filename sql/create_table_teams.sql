CREATE DATABASE IF NOT EXISTS sales_dashboard;

USE sales_dashboard;

CREATE TABLE teams (
    manager_id VARCHAR(50),
    team_leader_id VARCHAR(50),
    role VARCHAR(50)
);
