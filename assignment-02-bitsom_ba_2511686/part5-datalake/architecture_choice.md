## Architecture Recommendation

**Recommendation: Data Lakehouse**

For a fast-growing food delivery startup collecting GPS logs, customer text reviews, payment transactions, and restaurant menu images, a **Data Lakehouse** is the right architecture. Neither a pure Data Warehouse nor a plain Data Lake serves this use case well on its own — but the Lakehouse combines the strengths of both.

**Reason 1 — Heterogeneous data types.** The startup's data spans four fundamentally different formats: structured (payment transactions), semi-structured (GPS coordinates and logs), unstructured text (customer reviews), and binary (menu images). A traditional Data Warehouse (e.g., Snowflake, Redshift) is optimized for structured, schema-on-write data only — it cannot natively store raw GPS streams or image files. A plain Data Lake can store all of these, but lacks the query engine and governance layer needed for BI reporting on payments and customer metrics. The Lakehouse handles all four: raw files land in object storage (S3/GCS), and the table format layer (Delta Lake, Apache Iceberg) brings ACID transactions and SQL access on top.

**Reason 2 — Mixed workloads at scale.** The startup needs both operational analytics (real-time order tracking, driver location queries) and batch reporting (weekly revenue by restaurant, review sentiment trends). A warehouse handles batch SQL well but struggles with streaming ingestion. A Data Lake with a Lakehouse architecture supports both patterns: streaming ingestion (Kafka → Delta Lake) alongside batch SQL with DuckDB, Spark, or Trino.

**Reason 3 — Schema flexibility for a growing product.** A startup's data model evolves rapidly — new fields are added to orders, new event types appear in GPS logs, menu items change structure. Schema-on-read (the Lakehouse default) allows raw data to be stored first and structured later, avoiding costly schema migrations that would block a traditional warehouse.

**Reason 4 — Cost efficiency.** Object storage (S3/GCS) is orders of magnitude cheaper than warehouse compute storage. Since GPS logs alone can generate millions of events per day, storing everything in a warehouse would be prohibitively expensive. The Lakehouse keeps raw data in cheap object storage while enabling fast SQL queries via columnar formats like Parquet.

In summary, the Data Lakehouse is the only architecture that handles the full diversity of this startup's data, supports both streaming and batch workloads, stays flexible as the product grows, and remains cost-effective at scale.