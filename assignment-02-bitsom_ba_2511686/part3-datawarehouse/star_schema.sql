DROP TABLE IF EXISTS fact_sales;
DROP TABLE IF EXISTS dim_product;
DROP TABLE IF EXISTS dim_store;
DROP TABLE IF EXISTS dim_date;

-- ============================================================
-- Dimension 1: dim_date
-- ============================================================
CREATE TABLE dim_date (
    date_key INT NOT NULL,
    full_date  DATE NOT NULL,
    year SMALLINT NOT NULL,
    quarter TINYINT NOT NULL,
    month TINYINT NOT NULL,
    month_name VARCHAR(15) NOT NULL,
    day TINYINT NOT NULL,
    weekday VARCHAR(10) NOT NULL,
    is_weekend BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT pk_dim_date PRIMARY KEY (date_key)
);

INSERT INTO dim_date (date_key, full_date, year, quarter, month, month_name, day, weekday, is_weekend) VALUES
(20230115, '2023-01-15', 2023, 1,  1, 'January', 15, 'Sunday', TRUE),
(20230118, '2023-01-18', 2023, 1,  1, 'January', 18, 'Wednesday',FALSE),
(20230205, '2023-02-05', 2023, 1,  2, 'February', 5,  'Sunday', TRUE),
(20230208, '2023-02-08', 2023, 1,  2, 'February', 8,  'Wednesday', FALSE),
(20230220, '2023-02-20', 2023, 1,  2, 'February', 20, 'Monday', FALSE),
(20230307, '2023-03-07', 2023, 1,  3, 'March', 7,  'Tuesday', FALSE),
(20230331, '2023-03-31', 2023, 1,  3, 'March', 31, 'Friday', FALSE),
(20230406, '2023-04-06', 2023, 2,  4, 'April', 6,  'Thursday', FALSE),
(20230428, '2023-04-28', 2023, 2,  4, 'April', 28, 'Friday', FALSE),
(20230512, '2023-05-12', 2023, 2,  5, 'May', 12, 'Friday', FALSE),
(20230521, '2023-05-21', 2023, 2,  5, 'May', 21, 'Sunday', TRUE),
(20230604, '2023-06-04', 2023, 2,  6, 'June', 4,  'Sunday', TRUE),
(20230722, '2023-07-22', 2023, 3,  7, 'July', 22, 'Saturday', TRUE),
(20230801, '2023-08-01', 2023, 3,  8, 'August', 1,  'Tuesday', FALSE),
(20230809, '2023-08-09', 2023, 3,  8, 'August', 9,  'Wednesday', FALSE),
(20230815, '2023-08-15', 2023, 3,  8, 'August', 15, 'Tuesday', FALSE),
(20230829, '2023-08-29', 2023, 3,  8, 'August', 29, 'Tuesday', FALSE),
(20230908, '2023-09-08', 2023, 3,  9, 'September', 8,  'Friday', FALSE),
(20231020, '2023-10-20', 2023, 4,  10, 'October', 20, 'Friday', FALSE),
(20231026, '2023-10-26', 2023, 4,  10, 'October', 26, 'Thursday', FALSE),
(20231118, '2023-11-18', 2023, 4,  11, 'November', 18, 'Saturday', TRUE),
(20231208, '2023-12-08', 2023, 4,  12, 'December', 8,  'Friday', FALSE),
(20231212, '2023-12-12', 2023, 4,  12, 'December', 12, 'Tuesday', FALSE);


-- ============================================================
-- Dimension 2: dim_store
-- ============================================================
CREATE TABLE dim_store (
    store_key  INT NOT NULL AUTO_INCREMENT,
    store_name VARCHAR(100) NOT NULL,
    store_city VARCHAR(100) NOT NULL,
    store_zone VARCHAR(50) NOT NULL,
    CONSTRAINT pk_dim_store PRIMARY KEY (store_key)
);

INSERT INTO dim_store (store_key, store_name, store_city, store_zone) VALUES
(1, 'Chennai Anna', 'Chennai', 'South'),
(2, 'Delhi South', 'Delhi', 'North'),
(3, 'Bangalore MG', 'Bangalore', 'South'),
(4, 'Pune FC Road', 'Pune', 'West'),
(5, 'Mumbai Central', 'Mumbai', 'West');


-- ============================================================
-- Dimension 3: dim_product
-- ============================================================
CREATE TABLE dim_product (
    product_key  INT NOT NULL AUTO_INCREMENT,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50)  NOT NULL,
    CONSTRAINT pk_dim_product PRIMARY KEY (product_key)
);

INSERT INTO dim_product (product_key, product_name, category) VALUES
( 1, 'Jeans', 'Clothing'),
( 2, 'Jacket', 'Clothing'),
( 3, 'Saree', 'Clothing'),
( 4, 'T-Shirt', 'Clothing'),
( 5, 'Speaker', 'Electronics'),
( 6, 'Tablet', 'Electronics'),
( 7, 'Phone', 'Electronics'),
( 8, 'Smartwatch', 'Electronics'),
( 9, 'Laptop', 'Electronics'),
(10, 'Headphones','Electronics'),
(11, 'Atta 10kg', 'Groceries'),
(12, 'Biscuits', 'Groceries'),
(13, 'Milk 1L', 'Groceries'),
(14, 'Pulses 1kg', 'Groceries'),
(15, 'Rice 5kg', 'Groceries'),
(16, 'Oil 1L', 'Groceries');


-- ============================================================
-- Fact Table: fact_sales
-- ============================================================
CREATE TABLE fact_sales (
    sales_key INT NOT NULL AUTO_INCREMENT,
    transaction_id VARCHAR(15) NOT NULL,
    date_key INT NOT NULL,
    store_key INT NOT NULL,
    product_key INT NOT NULL,
    customer_id VARCHAR(20) NOT NULL,
    units_sold INT NOT NULL CHECK (units_sold > 0),
    unit_price DECIMAL(12,2) NOT NULL CHECK (unit_price >= 0),
    total_sales_amount DECIMAL(14,2) NOT NULL,   -- derived: units_sold * unit_price
    CONSTRAINT pk_fact_sales PRIMARY KEY (sales_key),
    CONSTRAINT fk_fs_date FOREIGN KEY (date_key) REFERENCES dim_date (date_key),
    CONSTRAINT fk_fs_store FOREIGN KEY (store_key) REFERENCES dim_store (store_key),
    CONSTRAINT fk_fs_product FOREIGN KEY (product_key) REFERENCES dim_product (product_key)
);

-- ============================================================
-- INSERT: 12 cleaned, standardized fact rows from raw CSV
-- ============================================================
INSERT INTO fact_sales (transaction_id, date_key, store_key, product_key, customer_id, units_sold, unit_price, total_sales_amount) VALUES
('TXN5000', 20230829, 1,  5,  'CUST045',  3,  49262.78,  147788.34),
('TXN5001', 20231212, 1,  6,  'CUST021', 11,  23226.12,  255487.32),
('TXN5002', 20230205, 1,  7,  'CUST019', 20,  48703.39,  974067.80),
('TXN5003', 20230220, 2,  6,  'CUST007', 14,  23226.12,  325165.68),
('TXN5005', 20230908, 3, 11,  'CUST027', 12,  52464.00,  629568.00),
('TXN5006', 20230331, 4,  8,  'CUST025',  6,  58851.01,  353106.06),
('TXN5007', 20231026, 4,  1,  'CUST041', 16,   2317.47,   37079.52),
('TXN5009', 20230815, 3,  8,  'CUST020',  3,  58851.01,  176553.03),
('TXN5010', 20230604, 1,  2,  'CUST031', 15,  30187.24,  452808.60),
('TXN5011', 20231020, 5,  1,  'CUST045', 13,   2317.47,   30127.11),
('TXN5013', 20230428, 5, 13,  'CUST015', 10,  43374.39,  433743.90),
('TXN5014', 20231118, 2,  2,  'CUST042',  5,  30187.24,  150936.20);