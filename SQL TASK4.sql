CREATE DATABASE ecommerce_db;
USE ecommerce_db;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    gender VARCHAR(10),
    email VARCHAR(255),
    country VARCHAR(100),
    city VARCHAR(100)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    status VARCHAR(50),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(255),
    category VARCHAR(100),
    price DECIMAL(10,2)
);

CREATE TABLE payments (
    payment_id INT PRIMARY KEY,
    order_id INT,
    payment_method VARCHAR(50),
    amount DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);
ALTER TABLE customers MODIFY gender VARCHAR(20);


INSERT INTO customers VALUES
(1, 'Alice', 'Johnson', 'alice@example.com', 'Female', 'USA', 'New York'),
(2, 'Bob', 'Smith', 'bob@example.com', 'Male', 'Canada', 'Toronto'),
(3, 'Charlie', 'Brown', 'charlie@example.com', 'Male', 'UK', 'London');

-- Products
INSERT INTO products VALUES
(101, 'Smartphone', 'Electronics', 699.99),
(102, 'Headphones', 'Electronics', 199.99),
(103, 'Book - Python 101', 'Books', 29.99);

-- Orders
INSERT INTO orders VALUES
(1001, 1, '2025-06-25', 'Shipped'),
(1002, 2, '2025-06-26', 'Processing'),
(1003, 1, '2025-06-27', 'Delivered');

-- Order Items
INSERT INTO order_items VALUES
(1, 1001, 101, 1, 699.99),
(2, 1001, 102, 2, 199.99),
(3, 1002, 103, 1, 29.99),
(4, 1003, 101, 1, 699.99);

-- Payments
INSERT INTO payments VALUES
(501, 1001, 'Credit Card', 1099.97),
(502, 1002, 'PayPal', 29.99),
(503, 1003, 'UPI', 699.99);





-- 1. Simple SELECT & WHERE
SELECT 
    customer_id, 
    CONCAT(first_name, ' ', last_name) AS name,
    country
FROM customers
WHERE country = 'USA'
ORDER BY name;


-- 2. Aggregate with GROUP BY
SELECT country, COUNT(*) AS num_customers
FROM customers
GROUP BY country
ORDER BY num_customers DESC;

-- 3. JOIN: Find orders with customer info
SELECT 
    o.order_id, 
    o.order_date, 
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name, 
    o.status
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_date > '2023-01-01'
ORDER BY o.order_date DESC
LIMIT 10000;


-- 4. JOIN across three tables
SELECT 
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name, 
    p.category, 
    SUM(oi.quantity * oi.price) AS total_spent
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN products p ON oi.product_id = p.product_id
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_id, p.category
ORDER BY total_spent DESC
LIMIT 10;


-- 5. Subquery: Products above average price
SELECT product_id, product_name, price
FROM products
WHERE price > (
  SELECT AVG(price)
  FROM products
)
LIMIT 10000;


-- 6. Subquery in SELECT: Customer total spend
SELECT 
  c.customer_id, 
  CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
  (
    SELECT SUM(oi.quantity * oi.price)
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.customer_id = c.customer_id
  ) AS total_spent
FROM customers c
ORDER BY total_spent DESC
LIMIT 5;


-- 7. Create VIEW
CREATE VIEW customer_spending AS
SELECT 
  c.customer_id, 
  CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
  SUM(oi.quantity * oi.price) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id;


-- 8. Index Optimization
CREATE INDEX idx_orders_customer ON orders(customer_id);
-- Run EXPLAIN on a query to check use of index:
EXPLAIN SELECT * FROM orders WHERE customer_id = 12345;

-- 9. Left Join and Right Join
SELECT 
  c.customer_id, 
  CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
  o.order_id,
  o.order_date
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
ORDER BY c.customer_id;

-- 10. Left and Right Join

SELECT 
  o.order_id,
  o.order_date,
  CONCAT(c.first_name, ' ', c.last_name) AS customer_name
FROM customers c
RIGHT JOIN orders o ON c.customer_id = o.customer_id
ORDER BY o.order_id;

