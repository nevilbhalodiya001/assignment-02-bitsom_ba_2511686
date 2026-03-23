DROP TABLE IF EXISTS OrderItems;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS SalesReps;

-- ============================================================
-- Table 1: SalesReps
-- ============================================================
CREATE TABLE SalesReps (
    sales_rep_id   VARCHAR(10)  NOT NULL,
    sales_rep_name VARCHAR(100) NOT NULL,
    sales_rep_email VARCHAR(150) NOT NULL,
    office_address  VARCHAR(255) NOT NULL,
    CONSTRAINT pk_sales_reps PRIMARY KEY (sales_rep_id)
);

INSERT INTO SalesReps (sales_rep_id, sales_rep_name, sales_rep_email, office_address) VALUES
    ('SR01', 'Deepak Joshi', 'deepak@corp.com', 'Mumbai HQ, Nariman Point, Mumbai - 400021'),
    ('SR02', 'Anita Desai',  'anita@corp.com',  'Delhi Office, Connaught Place, New Delhi - 110001'),
    ('SR03', 'Ravi Kumar',   'ravi@corp.com',   'South Zone, MG Road, Bangalore - 560001'),
    ('SR04', 'Meera Pillai', 'meera@corp.com',  'East Zone, Park Street, Kolkata - 700016'),
    ('SR05', 'Suresh Nair',  'suresh@corp.com', 'North Zone, Sector 18, Noida - 201301');

-- ============================================================
-- Table 2: Customers
-- ============================================================
CREATE TABLE Customers (
    customer_id    VARCHAR(10)  NOT NULL,
    customer_name  VARCHAR(100) NOT NULL,
    customer_email VARCHAR(150) NOT NULL,
    customer_city  VARCHAR(100) NOT NULL,
    CONSTRAINT pk_customers PRIMARY KEY (customer_id)
);

INSERT INTO Customers (customer_id, customer_name, customer_email, customer_city) VALUES
    ('C001', 'Rohan Mehta',  'rohan@gmail.com',  'Mumbai'),
    ('C002', 'Priya Sharma', 'priya@gmail.com',  'Delhi'),
    ('C003', 'Amit Verma',   'amit@gmail.com',   'Bangalore'),
    ('C004', 'Sneha Iyer',   'sneha@gmail.com',  'Chennai'),
    ('C005', 'Vikram Singh', 'vikram@gmail.com', 'Mumbai'),
    ('C006', 'Neha Gupta',   'neha@gmail.com',   'Delhi'),
    ('C007', 'Arjun Nair',   'arjun@gmail.com',  'Bangalore'),
    ('C008', 'Kavya Rao',    'kavya@gmail.com',  'Hyderabad');

-- ============================================================
-- Table 3: Products
-- ============================================================
CREATE TABLE Products (
    product_id   VARCHAR(10)  NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    category     VARCHAR(100) NOT NULL,
    unit_price   DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
    CONSTRAINT pk_products PRIMARY KEY (product_id)
);

INSERT INTO Products (product_id, product_name, category, unit_price) VALUES
    ('P001', 'Laptop',        'Electronics', 55000.00),
    ('P002', 'Mouse',         'Electronics',   800.00),
    ('P003', 'Desk Chair',    'Furniture',    8500.00),
    ('P004', 'Notebook',      'Stationery',    120.00),
    ('P005', 'Headphones',    'Electronics',  3200.00),
    ('P006', 'Standing Desk', 'Furniture',   22000.00),
    ('P007', 'Pen Set',       'Stationery',    250.00),
    ('P008', 'Webcam',        'Electronics',  2100.00);

-- ============================================================
-- Table 4: Orders
-- ============================================================
CREATE TABLE Orders (
    order_id     VARCHAR(15)  NOT NULL,
    customer_id  VARCHAR(10)  NOT NULL,
    sales_rep_id VARCHAR(10)  NOT NULL,
    order_date   DATE         NOT NULL,
    CONSTRAINT pk_orders      PRIMARY KEY (order_id),
    CONSTRAINT fk_ord_cust    FOREIGN KEY (customer_id)  REFERENCES Customers (customer_id),
    CONSTRAINT fk_ord_sr      FOREIGN KEY (sales_rep_id) REFERENCES SalesReps (sales_rep_id)
);

INSERT INTO Orders (order_id, customer_id, sales_rep_id, order_date) VALUES
    ('ORD1001', 'C003', 'SR03', '2023-05-15'),
    ('ORD1002', 'C002', 'SR02', '2023-01-17'),
    ('ORD1003', 'C001', 'SR01', '2023-09-22'),
    ('ORD1004', 'C005', 'SR01', '2023-06-10'),
    ('ORD1005', 'C004', 'SR03', '2023-03-28'),
    ('ORD1006', 'C008', 'SR01', '2023-07-14'),
    ('ORD1007', 'C006', 'SR01', '2023-11-05'),
    ('ORD1008', 'C007', 'SR02', '2023-08-19'),
    ('ORD1009', 'C006', 'SR03', '2023-04-02'),
    ('ORD1010', 'C001', 'SR01', '2023-12-01');

-- ============================================================
-- Table 5: OrderItems
-- ============================================================
CREATE TABLE OrderItems (
    item_id    INT           NOT NULL AUTO_INCREMENT,
    order_id   VARCHAR(15)   NOT NULL,
    product_id VARCHAR(10)   NOT NULL,
    quantity   INT           NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),  -- price at time of order
    CONSTRAINT pk_order_items  PRIMARY KEY (item_id),
    CONSTRAINT fk_oi_order     FOREIGN KEY (order_id)   REFERENCES Orders   (order_id),
    CONSTRAINT fk_oi_product   FOREIGN KEY (product_id) REFERENCES Products (product_id)
);

INSERT INTO OrderItems (order_id, product_id, quantity, unit_price) VALUES
    ('ORD1001', 'P001', 2,  55000.00),
    ('ORD1002', 'P005', 1,   3200.00),
    ('ORD1003', 'P006', 3,  22000.00),
    ('ORD1004', 'P003', 2,   8500.00),
    ('ORD1005', 'P002', 5,    800.00),
    ('ORD1006', 'P008', 4,   2100.00),
    ('ORD1007', 'P004', 6,    120.00),
    ('ORD1008', 'P007', 3,    250.00),
    ('ORD1009', 'P005', 4,   3200.00),
    ('ORD1010', 'P002', 2,    800.00);