## ETL Decisions

## Decision 1 — Date Format Cleanup
Problem:
The date column had dates written in three different formats across 300 rows:

DD/MM/YYYY — like 29/08/2023
DD-MM-YYYY — like 12-12-2023
YYYY-MM-DD — like 2023-02-05

Because of this, a single date parser was failing. There was also a risk of mixing up day and month in dates like 12-02-2023.
What I did:
Used pandas pd.to_datetime(df['date'], format='mixed', dayfirst=True) which handles each row's format separately. The dayfirst=True setting makes sure ambiguous dates are treated as day-first. After parsing, all dates were converted to YYYY-MM-DD format and then turned into an integer date_key like 20230115. All 300 rows were parsed with no errors.

## Decision 2 — Category Name Inconsistency
Problem:
The category column had 5 different values for what should be only 3 categories:
Raw ValueCountIssueGrocery87Should be GroceriesGroceries40Correctelectronics41Should be ElectronicsElectronics60CorrectClothing72Correct
This would cause GROUP BY queries to split the same category into two rows and give wrong revenue totals.
What I did:
Created a mapping dictionary to fix all values:
pythoncat_map = {
    'electronics': 'Electronics',
    'Grocery':     'Groceries',
    'Groceries':   'Groceries',
    'Electronics': 'Electronics',
    'Clothing':    'Clothing'
}
df['category'] = df['category'].map(cat_map)
I used an explicit dictionary instead of just .str.title() because .str.title() would silently fix any future wrong values without flagging them.

## Decision 3 — Missing store_city Values
Problem:
19 rows out of 300 had NULL in the store_city column. If left as NULL, those rows would be ignored in any city-level reports, which would make the revenue numbers look lower than they actually are.
The good thing was that every row with a NULL city still had a valid store_name, and each store name always maps to the same city, so the missing values could be filled in reliably.
What I did:
Created a lookup dictionary to fill in city from store name:
pythonstore_city_map = {
    'Chennai Anna':   'Chennai',
    'Delhi South':    'Delhi',
    'Bangalore MG':   'Bangalore',
    'Mumbai Central': 'Mumbai',
    'Pune FC Road':   'Pune'
}
df['store_city'] = df['store_name'].map(store_city_map)
This replaces all city values, not just the NULLs, so even rows where the city was already filled but maybe misspelled get corrected. After this, store_city was marked as NOT NULL in the table.