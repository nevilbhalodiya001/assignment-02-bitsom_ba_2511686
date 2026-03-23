const db = db.getSiblingDB("ecommerce");
const products = db.products;

// ============================================================
// OP1: insertMany() — insert all 3 documents from sample_documents.json
// ============================================================

const fs   = require("fs");
const docs = JSON.parse(fs.readFileSync("sample_documents.json", "utf8"));

const insertResult = products.insertMany(docs);
print("OP1 — Inserted document IDs:");
printjson(insertResult.insertedIds);


// ============================================================
// OP2: find() — retrieve all Electronics products with price > 20000
// ============================================================

print("\nOP2 — Electronics products with price > 20000:");
const electronics = products.find(
    { category: "Electronics", price: { $gt: 20000 } },
    { _id: 0, product_id: 1, name: 1, brand: 1, price: 1, rating: 1 }
).toArray();
printjson(electronics);


// ============================================================
// OP3: find() — retrieve all Groceries expiring before 2025-01-01
// ============================================================

print("\nOP3 — Groceries expiring before 2025-01-01:");
const expiringGroceries = products.find(
    {
        category: "Groceries",
        "specifications.expiry_date": { $lt: new Date("2025-01-01") }
    },
    {
        _id: 0,
        product_id: 1,
        name: 1,
        "specifications.expiry_date": 1,
        "specifications.shelf_life_days": 1
    }
).toArray();
printjson(expiringGroceries);


// ============================================================
// OP4: updateOne() — add a "discount_percent" field to a specific product
// Here we add a 10% discount to the Sony Headphones (ELEC-001).
// ============================================================

print("\nOP4 — Adding discount_percent to product ELEC-001:");
const updateResult = products.updateOne(
    { product_id: "ELEC-001" },
    {
        $set: {
            discount_percent: 10,
            discounted_price: 26999,
            updated_at: new Date()
        }
    }
);
print(`  Matched: ${updateResult.matchedCount}, Modified: ${updateResult.modifiedCount}`);

// Verify the update
const updatedDoc = products.findOne(
    { product_id: "ELEC-001" },
    { _id: 0, product_id: 1, name: 1, price: 1, discount_percent: 1, discounted_price: 1 }
);
printjson(updatedDoc);


// ============================================================
// OP5: createIndex() — create an index on the category field
// ============================================================

print("\nOP5 — Creating index on { category: 1 }:");
const indexName = products.createIndex(
    { category: 1 },
    { name: "idx_category"}
);
print(`  Index created: ${indexName}`);

// Compound index for category + price (covers OP2 pattern)
print("\nOP5 — Creating compound index on { category: 1, price: 1 }:");
const compoundIndex = products.createIndex(
    { category: 1, price: 1 },
    { name: "idx_category_price", background: true }
);
print(`  Compound index created: ${compoundIndex}`);

// Verify with explain — should show IXSCAN, not COLLSCAN
print("\nOP5 — explain() output for OP2 query (should show IXSCAN):");
const explainResult = products.find(
    { category: "Electronics", price: { $gt: 20000 } }
).explain("executionStats");
print(`  Stage used: ${explainResult.queryPlanner.winningPlan.inputStage?.stage ?? explainResult.queryPlanner.winningPlan.stage}`);
print(`  Index used: ${explainResult.queryPlanner.winningPlan.inputStage?.indexName ?? "N/A"}`);