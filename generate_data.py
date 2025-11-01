"""
generate_data.py

Генерирует тестовые CSV-файлы для BI-проекта и SQL-скрипты CREATE TABLE для импорта в DBeaver.
Idempotent: пересоздаёт файлы, если они уже существуют.

Требования:
    pip install pandas numpy

Запуск:
    python generate_data.py

Результат:
    ./data_sample/
        products.csv
        clients.csv
        orders.csv
        order_lines.csv
        sales.csv
        returns.csv
        plans.csv
        teams.csv
    ./sql/
        create_tables.sql
        create_table_<table>.sql (по таблице)

ВАЖНО ДЛЯ DBEAVER (РУССКАЯ ВЕРСИЯ):
    После генерации SQL-скрипта выполните его в DBeaver через:
    Редактор SQL -> Выполнить SQL-скрипт (Alt+X) - выделив ВЕСЬ текст скрипта
"""

import os
import shutil
from datetime import datetime, timedelta
import random

import numpy as np
import pandas as pd

# ------------- Параметры генерации -------------
SEED = 42
random.seed(SEED)
np.random.seed(SEED)

OUT_DIR = "data_sample"
SQL_DIR = "sql"

N_PRODUCTS = 30          # число уникальных артикулов
N_CLIENTS = 40
N_MANAGERS = 6
N_ORDERS = 400           # число заказов (строк заказов)
MAX_LINES_PER_ORDER = 4  # сколько позиций в заказе (будем рандомить)
DATE_START = datetime(2025, 1, 1)
DATE_END = datetime(2025, 10, 1)

# ------------- Вспомогательные функции -------------
def ensure_dir(d):
    if os.path.exists(d):
        # очищаем старые файлы для idempotency (по желанию можно не удалять папку)
        pass
    else:
        os.makedirs(d, exist_ok=True)

def remove_if_exists(path):
    if os.path.exists(path):
        if os.path.isdir(path):
            shutil.rmtree(path)
        else:
            os.remove(path)

def save_csv(df, path):
    # сохраняем в utf-8 с BOM, чтобы Excel/PowerBI корректно распознавали кодировку
    df.to_csv(path, index=False, encoding='utf-8-sig')
    print(f"Saved {path} ({len(df)} rows)")

# ------------- Создаём папки (пересоздаём для чистоты) -------------
remove_if_exists(OUT_DIR)
remove_if_exists(SQL_DIR)
ensure_dir(OUT_DIR)
ensure_dir(SQL_DIR)

# ------------- 1) products (артикулы) -------------
articles = [f"ART{idx:04d}" for idx in range(1, N_PRODUCTS + 1)]
categories = ['Одежда', 'Обувь', 'Аксессуары', 'Товары для дома', 'Электроника']
products = pd.DataFrame({
    'article': articles,
    'product_name': [f"Товар {i}" for i in range(1, N_PRODUCTS + 1)],
    'category': np.random.choice(categories, N_PRODUCTS),
    'cost': np.random.randint(300, 8000, N_PRODUCTS)  # себестоимость
})
save_csv(products, os.path.join(OUT_DIR, "products.csv"))

# ------------- 2) managers / teams / team_leaders -------------
managers = [f"M{idx:02d}" for idx in range(1, N_MANAGERS + 1)]
team_leaders = [f"TL{idx:02d}" for idx in range(1, max(2, N_MANAGERS//2) + 1)]

# teams: каждый менеджер в одной команде, у team_leader может быть несколько менеджеров
teams_rows = []
for i, m in enumerate(managers):
    tl = random.choice(team_leaders)
    role = 'manager'
    teams_rows.append({'manager_id': m, 'team_leader_id': tl, 'role': role})
teams = pd.DataFrame(teams_rows)
save_csv(teams, os.path.join(OUT_DIR, "teams.csv"))

# ------------- 3) clients -------------
clients = pd.DataFrame({
    'client_id': [f"C{idx:04d}" for idx in range(1, N_CLIENTS + 1)],
    'client_name': [f"ООО Клиент {i}" for i in range(1, N_CLIENTS + 1)],
    'inn': [str(7700000000 + idx) for idx in range(1, N_CLIENTS + 1)],
    'manager_id': np.random.choice(managers, N_CLIENTS)
})
save_csv(clients, os.path.join(OUT_DIR, "clients.csv"))

# ------------- 4) orders + order_lines -------------
order_rows = []
order_lines_rows = []
order_id_seq = 1
ol_id_seq = 1

date_range_days = (DATE_END - DATE_START).days

for _ in range(N_ORDERS):
    order_id = f"O{order_id_seq:05d}"
    order_date = DATE_START + timedelta(days=random.randint(0, max(0, date_range_days-1)))
    client = clients.sample(1).iloc[0]
    client_id = client['client_id']
    # определим сколько линий в заказе
    lines_in_order = random.randint(1, MAX_LINES_PER_ORDER)
    order_total = 0
    for l in range(lines_in_order):
        article = products.sample(1).iloc[0]
        article_code = article['article']
        qty = random.randint(1, 5)
        # price — продажная цена, не ниже себестоимости и с наценкой
        base_cost = int(article['cost'])
        price = int(base_cost * random.uniform(1.1, 2.5))
        line_sum = price * qty
        # margin per line: либо из стоимости, либо заданная случайно
        line_margin = round(line_sum * random.uniform(0.05, 0.35), 2)
        # append order_line
        order_lines_rows.append({
            'order_line_id': f"OL{ol_id_seq:06d}",
            'order_id': order_id,
            'article': article_code,
            'quantity': qty,
            'price': price,
            'line_sum': line_sum,
            'line_margin': line_margin
        })
        ol_id_seq += 1
        order_total += line_sum

    order_rows.append({
        'order_id': order_id,
        'client_id': client_id,
        'order_date': order_date.strftime('%Y-%m-%d'),
        'order_total': order_total,
        'manager_id': client['manager_id']
    })
    order_id_seq += 1

orders = pd.DataFrame(order_rows)
order_lines = pd.DataFrame(order_lines_rows)
save_csv(orders, os.path.join(OUT_DIR, "orders.csv"))
save_csv(order_lines, os.path.join(OUT_DIR, "order_lines.csv"))

# ------------- 5) sales (реализации) -------------
# Возьмём часть order_lines как продажи (например, 85% продано), каждая продажа с уникальным sale_id
sold_mask = np.random.rand(len(order_lines)) < 0.85
sold_lines = order_lines[sold_mask].copy().reset_index(drop=True)
sold_lines['sale_id'] = [f"S{idx:06d}" for idx in range(1, len(sold_lines)+1)]
sold_lines['sale_amount'] = sold_lines['line_sum']  # упрощение: sale_amount = line_sum
sales = sold_lines[['sale_id', 'order_id', 'article', 'quantity', 'sale_amount']]
save_csv(sales, os.path.join(OUT_DIR, "sales.csv"))

# ------------- 6) returns (корректировки реализаций) -------------
# Берём небольшую часть продаж как возвраты
return_mask = np.random.rand(len(sales)) < 0.08
returns_sample = sales[return_mask].copy().reset_index(drop=True)
returns_sample['return_id'] = [f"R{idx:06d}" for idx in range(1, len(returns_sample)+1)]
# пусть возвращают случайное количество <= проданного
returns_sample['return_quantity'] = returns_sample['quantity'].apply(lambda q: random.randint(1, max(1, int(q))))
returns_sample['return_amount'] = (returns_sample['sale_amount'] / returns_sample['quantity']) * returns_sample['return_quantity']
returns = returns_sample[['return_id', 'sale_id', 'article', 'return_quantity', 'return_amount']]
save_csv(returns, os.path.join(OUT_DIR, "returns.csv"))

# ------------- 7) plans (плановые показатели по менеджеру на месяц) -------------
# Создадим планы на месяцы между DATE_START и DATE_END для каждого менеджера
plans_rows = []
# генерируем месяцы
months = []
cur = DATE_START.replace(day=1)
end_month = DATE_END.replace(day=1)
while cur <= end_month:
    months.append(cur.strftime('%Y-%m'))
    # move to next month
    year = cur.year + (cur.month // 12)
    month = (cur.month % 12) + 1
    cur = cur.replace(year=year, month=month, day=1)

for m in managers:
    for per in months:
        plan_revenue = int(np.random.randint(150000, 450000))
        plan_margin = int(plan_revenue * random.uniform(0.12, 0.28))
        plans_rows.append({
            'manager_id': m,
            'period_month': per,
            'plan_revenue': plan_revenue,
            'plan_margin': plan_margin
        })
plans = pd.DataFrame(plans_rows)
save_csv(plans, os.path.join(OUT_DIR, "plans.csv"))

# ------------- 8) Сохраняем SQL-скрипты CREATE TABLE -------------

create_table_templates = {
    'products': """
CREATE TABLE products (
    article VARCHAR(50) PRIMARY KEY,
    product_name VARCHAR(255),
    category VARCHAR(100),
    cost INTEGER
);
""",
    'clients': """
CREATE TABLE clients (
    client_id VARCHAR(50) PRIMARY KEY,
    client_name VARCHAR(255),
    inn VARCHAR(50),
    manager_id VARCHAR(50)
);
""",
    'teams': """
CREATE TABLE teams (
    manager_id VARCHAR(50),
    team_leader_id VARCHAR(50),
    role VARCHAR(50)
);
""",
    'orders': """
CREATE TABLE orders (
    order_id VARCHAR(50) PRIMARY KEY,
    client_id VARCHAR(50),
    order_date DATE,
    order_total NUMERIC,
    manager_id VARCHAR(50)
);
""",
    'order_lines': """
CREATE TABLE order_lines (
    order_line_id VARCHAR(50) PRIMARY KEY,
    order_id VARCHAR(50),
    article VARCHAR(50),
    quantity INTEGER,
    price NUMERIC,
    line_sum NUMERIC,
    line_margin NUMERIC
);
""",
    'sales': """
CREATE TABLE sales (
    sale_id VARCHAR(50) PRIMARY KEY,
    order_id VARCHAR(50),
    article VARCHAR(50),
    quantity INTEGER,
    sale_amount NUMERIC
);
""",
    'returns': """
CREATE TABLE returns (
    return_id VARCHAR(50) PRIMARY KEY,
    sale_id VARCHAR(50),
    article VARCHAR(50),
    return_quantity INTEGER,
    return_amount NUMERIC
);
""",
    'plans': """
CREATE TABLE plans (
    manager_id VARCHAR(50),
    period_month VARCHAR(10),
    plan_revenue NUMERIC,
    plan_margin NUMERIC
);
"""
}

# save combined create_tables.sql с созданием базы данных
with open(os.path.join(SQL_DIR, "create_tables.sql"), "w", encoding="utf-8") as f:
    f.write("-- SQL скрипт для создания базы данных и таблиц\n")
    f.write("-- В DBEAVER (русская версия): выделить ВЕСЬ текст и выполнить через Редактор SQL -> Выполнить SQL-скрипт (Alt+X)\n\n")

    f.write("-- Создание базы данных\n")
    f.write("CREATE DATABASE IF NOT EXISTS sales_dashboard;\n\n")

    f.write("-- Использование базы данных\n")
    f.write("USE sales_dashboard;\n\n")

    f.write("-- Создание таблиц\n")
    for name, sql in create_table_templates.items():
        f.write(f"-- Таблица: {name}\n")
        f.write(sql.strip() + "\n\n")

    f.write("-- Скрипт завершен. Теперь можно импортировать CSV файлы из папки data_sample/\n")
print(f"Saved SQL create script: {os.path.join(SQL_DIR, 'create_tables.sql')}")

# save individual files
for name, sql in create_table_templates.items():
    path = os.path.join(SQL_DIR, f"create_table_{name}.sql")
    with open(path, "w", encoding="utf-8") as f:
        f.write("CREATE DATABASE IF NOT EXISTS sales_dashboard;\n\n")
        f.write("USE sales_dashboard;\n\n")
        f.write(sql.strip() + "\n")
    print(f"Saved {path}")

print("\n" + "="*60)
print("Генерация завершена! Файлы находятся в папке data_sample/ и sql/.")
print("\nВАЖНО ДЛЯ DBEAVER (РУССКАЯ ВЕРСИЯ):")
print("1. Откройте файл sql/create_tables.sql в DBeaver")
print("2. Выделите ВЕСЬ текст скрипта")
print("3. Выполните через: Редактор SQL -> Выполнить SQL-скрипт (Alt+X)")
print("4. После создания таблиц импортируйте CSV файлы из data_sample/")
print("="*60)