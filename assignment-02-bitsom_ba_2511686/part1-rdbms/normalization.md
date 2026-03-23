## Anomaly Analysis

### 1. Insert Anomaly

**Definition:** You cannot insert a fact about one entity without having data about another entity.

**Example from the dataset:**  
Suppose the company hires a new sales representative — say 'SR04 Meera Pillai' — before she handles any order. we can't add Meera's details (name, email, office address) into the table because every row requires an 'orderID'. Her record can only exist if an order is placed first.

Similarly, a new product (e.g., 'P009 Whiteboard') cannot be added to the catalogue until at least one customer orders it.

**Affected columns:** 'sales_rep_id', 'sales_rep_name', 'sales_rep_email', 'office_address', 'product_id', 'product_name', 'category', 'unit_price'

### 2. Update Anomaly

**Definition:** Changing a single real-world fact requires updating many rows; if any row is missed, the data becomes inconsistent.

**Example from the dataset:**  
Sales rep 'SR01 (Deepak Joshi)' appears in 83 rows. His office address is stored as two different strings across those rows:

| order_id | office_address |
|----------|----------------|
| ORD1114  | 'Mumbai HQ, Nariman Point, Mumbai - 400021' |
| ORD1180  | 'Mumbai HQ, Nariman Pt, Mumbai - 400021' *(abbreviated "Pt")* |

The same physical address is spelled differently in at least 15 rows (ORD1180, ORD1173, ORD1170, ORD1183, ORD1181, ORD1184, ORD1172, ORD1182, ORD1177, ORD1178, ORD1174, ORD1179, ORD1171, ORD1175, ORD1176). This is a direct consequence of the update anomaly: when the address was edited, not all rows were updated consistently.
**Affected columns:** 'office_address' (for 'sales_rep_id = SR01')

### 3. Delete Anomaly

**Definition:** Deleting a row to remove one fact accidentally destroys other unrelated facts.

**Example from the dataset:**  
'Customer C004 Sneha Iyer' from Chennai has placed orders. If all of Sneha Iyer's orders are cancelled and deleted from the table, **all information about her** — name, email, city — is permanently lost. Likewise, if every order containing 'P008 Webcam' is deleted, the product's name, category, and price are erased from the database entirely.

**Affected columns:** 'customer_id', 'customer_name', 'customer_email', 'customer_city' — and 'product_id', 'product_name', 'category', 'unit_price'


## Normalization Justification

*"Your manager argues that keeping everything in one table is simpler and normalization is over-engineering. Using specific examples from the dataset, defend or refute this position."*

The argument that a single flat table is "simpler" is appealing on the surface — there are no joins, no foreign keys, and the data is immediately visible in one place. However, the 'orders_flat.csv' dataset itself demonstrates clearly why this simplicity is an illusion that creates real, measurable problems.

The most concrete evidence is the address inconsistency for 'SR01 Deepak Joshi'. His office address appears in 83 rows, and at least 15 of them use a shortened form — '"Nariman Pt"' instead of '"Nariman Point"'. This is not a hypothetical risk; it is a bug that already exists in the data. If a report filters on the address string, it will silently exclude those 15 rows. Fixing it requires finding and updating every affected row — a fragile, error-prone operation that would not be necessary if the sales rep's address were stored once in a 'SalesReps' table.

The delete anomaly is equally damaging. If a customer like 'C004 Sneha Iyer' cancels all her orders, her contact details vanish from the system. A business that wants to re-engage her through a marketing campaign would find no record. In a normalized schema, the 'Customers' table retains her information independently of whether she has active orders.

The insert anomaly means the company cannot onboard a new product or sales representative in the system until an order happens to include them. This creates a dependency between operational data (orders) and reference data (products, staff) that does not reflect reality.

Normalization to 3NF addresses all three anomalies by ensuring that every non-key attribute depends only on the primary key of its own table — nothing more, nothing less. The resulting schema ('Customers', 'Products', 'SalesReps', 'Orders', 'OrderItems') stores each fact exactly once. Yes, queries now require joins, but modern databases execute joins efficiently with proper indexes, and the cost of a join is far lower than the cost of corrupted or missing data. The flat-file approach trades a short-term convenience for long-term data integrity problems. The evidence is already in the dataset.