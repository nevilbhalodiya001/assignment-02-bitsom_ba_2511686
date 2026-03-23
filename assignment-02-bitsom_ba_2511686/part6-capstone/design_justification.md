## Storage Systems

The architecture maps each of the four hospital goals to the storage system best suited for its access pattern and data type.

**Goal 1 — Predict patient readmission risk** uses a **Data Lakehouse (Delta Lake on S3/GCS)** as the primary storage layer for historical training data. Patient records, lab results, discharge summaries, and treatment histories arrive from the EHR system via batch ETL (Apache Spark / dbt) and land in the Lakehouse as Parquet files with ACID transaction guarantees. This gives the ML team schema-on-read flexibility (medical data schemas evolve constantly), versioned datasets for reproducible model training, and cost-efficient storage of years of historical records. The trained model and its versions are tracked in **MLflow (Model Registry)**.

**Goal 2 — Allow doctors to query patient history in plain English** uses a **Vector Database (Weaviate)**. Unstructured doctor notes, discharge summaries, and PDF reports are chunked and embedded using a medical language model (e.g., BioMedLM or ClinicalBERT). These embeddings are stored in Weaviate. When a doctor asks *"Has this patient had a cardiac event before?"*, the query is embedded and an approximate nearest-neighbour search retrieves the most semantically relevant passages, which are then synthesized by an LLM in a RAG pipeline. A keyword-based SQL search would miss synonymous clinical terminology entirely.

**Goal 3 — Generate monthly reports** uses a **Data Warehouse (Snowflake or BigQuery)**. Structured operational data — bed occupancy, department-wise costs, procedure counts — is loaded from PostgreSQL (OLTP) into the warehouse via nightly ETL jobs. The warehouse's columnar storage and massively parallel query engine make aggregation queries over millions of rows fast and cost-effective. DuckDB is used locally by analysts for ad-hoc OLAP queries directly on Parquet files from the Lakehouse.

**Goal 4 — Stream and store real-time ICU vitals** uses **Apache Kafka** for ingestion and **TimescaleDB** for storage. ICU devices emit hundreds of data points per second (heart rate, SpO₂, blood pressure). Kafka handles the high-throughput streaming ingestion reliably, and TimescaleDB — a time-series extension of PostgreSQL — stores the vitals with automatic partitioning by time, enabling fast range queries like *"Show SpO₂ readings for patient X in the last 6 hours."* Kafka Streams processes the data in real-time to trigger alerts when vitals cross threshold values.

---

## OLTP vs OLAP Boundary

The OLTP system ends at **PostgreSQL** (patient records, admissions, billing transactions) and **TimescaleDB** (ICU vitals). These systems are optimized for transactional writes — low-latency inserts and point lookups with ACID guarantees. They serve the live hospital operations: admitting patients, recording vitals, updating treatment notes.

The OLAP boundary begins at the **Data Lakehouse and Data Warehouse**. Data crosses this boundary via two paths: nightly batch ETL (Spark/dbt jobs extract from PostgreSQL and load cleaned, transformed data into Snowflake/Delta Lake) and near-real-time streaming ETL (Kafka → Spark Streaming → Delta Lake for ICU data). Once in the analytical layer, data is immutable and optimized for read-heavy aggregations — monthly reports, ML feature engineering, and trend analysis. No application writes to the warehouse directly.

The architectural diagram marks this boundary explicitly with a dashed vertical line between TimescaleDB (OLTP) and the Data Lakehouse (OLAP).

---

## Trade-offs

**Significant trade-off: System complexity vs. data freshness.**

The layered architecture — Kafka → Spark → Delta Lake → Snowflake → BI Dashboard — introduces pipeline latency. A piece of data recorded in the ICU may take 15–30 minutes to appear in a management report, and nightly ETL means some Snowflake reports are up to 24 hours stale. This is acceptable for monthly reports but could be problematic if management ever needs near-real-time operational dashboards.

Additionally, maintaining five distinct storage systems (PostgreSQL, TimescaleDB, Delta Lake, Snowflake, Weaviate) requires specialist skills across RDBMS administration, data engineering, cloud object storage, and ML infrastructure. For a mid-sized hospital, this operational burden is non-trivial.

**Mitigation:** The staleness problem can be partially addressed by exposing Kafka topics directly to a streaming analytics layer (e.g., Apache Flink or ksqlDB) for dashboards that need sub-minute freshness, while keeping the warehouse for certified monthly reports. The complexity problem is mitigated by adopting a managed cloud platform (e.g., Databricks Lakehouse Platform) that unifies the Delta Lake, Spark, and ML Registry layers under a single managed service, reducing the operational surface area from five systems to three.