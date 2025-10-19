DROP TABLE IF EXISTS transactions;

CREATE TABLE transactions (
    "Transaction ID" TEXT,
    "Customer ID" TEXT,
    "Category" TEXT,
    "Item" TEXT,
    "Price Per Unit" FLOAT,
    "Quantity" FLOAT,
    "Total Spent" FLOAT,
    "Payment Method" TEXT,
    "Location" TEXT,
    "Transaction Date" TIMESTAMP,
    "Discount Applied" BOOLEAN
);

COPY transactions (
    "Transaction ID",
    "Customer ID",
    "Category",
    "Item",
    "Price Per Unit",
    "Quantity",
    "Total Spent",
    "Payment Method",
    "Location",
    "Transaction Date",
    "Discount Applied"
)
FROM 'C:\Program Files\Analysis\Urban Basket Sales 2024.csv'
DELIMITER ','
CSV HEADER;

-- Rename columns from spaced names to snake_case.
ALTER TABLE transactions RENAME COLUMN "Transaction ID" TO transaction_id;
ALTER TABLE transactions RENAME COLUMN "Customer ID" TO customer_id;
ALTER TABLE transactions RENAME COLUMN "Category" TO category;
ALTER TABLE transactions RENAME COLUMN "Item" TO item;
ALTER TABLE transactions RENAME COLUMN "Price Per Unit" TO price_per_unit;
ALTER TABLE transactions RENAME COLUMN "Quantity" TO quantity;
ALTER TABLE transactions RENAME COLUMN "Total Spent" TO total_spent;
ALTER TABLE transactions RENAME COLUMN "Payment Method" TO payment_method;
ALTER TABLE transactions RENAME COLUMN "Location" TO location;
ALTER TABLE transactions RENAME COLUMN "Transaction Date" TO transaction_date;
ALTER TABLE transactions RENAME COLUMN "Discount Applied" TO discount_applied;

-- Changing Datatype.
ALTER TABLE transactions
ALTER COLUMN "quantity" TYPE INT
USING ROUND("quantity")::INT;

-- Turning all empty ' ' strings into null values and removing spaces in front or back of strings.
UPDATE transactions
SET
  "transaction_id" = NULLIF(TRIM("transaction_id"), ''),
  "customer_id"    = NULLIF(TRIM("customer_id"), ''),
  "category"       = NULLIF(TRIM("category"), ''),
  "item"           = NULLIF(TRIM("item"), ''),
  "payment_method" = NULLIF(TRIM("payment_method"), ''),
  "location"       = NULLIF(TRIM("location"), '');


-- 1. If null values are small and can be updated manually.
-- SELECT *
-- FROM transactions
-- WHERE "item" IS NULL;

-- UPDATE transactions
-- SET "item" = "item_17_Milk"
-- WHERE "transaction_id" = 'TXN00123';

-- 2. If not manually, replacing categorical data with 'unknown'.
UPDATE transactions
SET "item" = 'Unknown'
WHERE "item" IS NULL;

COMMIT;

-- Accessing Min, Max and Avg Values of price_per_unit to select right avg to replace nulls with.
-- SELECT MAX("price_per_unit") AS max_ppu,
-- MIN("price_per_unit") AS min_ppu,
-- AVG("price_per_unit") AS avg_ppu
-- FROM transactions
-- WHERE "price_per_unit" IS NOT NULL;

-- Replacing price_per_unit Nulls with Mean.
WITH mean AS (
    SELECT AVG("price_per_unit") AS avg_ppu
    FROM transactions
    WHERE "price_per_unit" IS NOT NULL
)

UPDATE transactions
SET "price_per_unit" = (SELECT avg_ppu FROM mean)
WHERE "price_per_unit" IS NULL;


-- Replacing the quantity nulls to mode after accessing the min, max and avg values.
-- SELECT "quantity", COUNT(*) AS count
-- FROM transactions
-- WHERE "quantity" IS NOT NULL
-- GROUP BY "quantity"
-- ORDER BY count DESC
-- LIMIT 1;
-- Mode is on one extreme and not appropriate to replace all nulls with, replacing might lead to distort distribution.

-- Replacing the quantity nulls to rounded mean.
WITH mean2 AS (
    SELECT ROUND(AVG("quantity")) AS avg_q
    FROM transactions
    WHERE "quantity" IS NOT NULL
)

UPDATE transactions
SET "quantity" = (SELECT avg_q FROM mean2)
WHERE "quantity" IS NULL;

-- Replacing total_spent Nulls with Median after accessing the min, max and avg.
WITH median_cte AS (
    SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY "total_spent") AS median_total_spent
    FROM transactions
    WHERE "total_spent" IS NOT NULL
)
UPDATE transactions
SET "total_spent" = (SELECT median_total_spent FROM median_cte)
WHERE "total_spent" IS NULL;

-- discount_applied (Nulls - 4199, True - 4219, False - 4157)

--Cleaning Duplicates
-- SELECT "transaction_id", COUNT(*) AS count
-- FROM transactions
-- GROUP BY "transaction_id"
-- HAVING COUNT(*) > 1;

-- No Duplicates found. if found, then:

-- DELETE FROM transactions
-- WHERE ctid NOT IN (
--     SELECT MIN(ctid)
--     FROM transactions
--     GROUP BY "transaction_id"
-- );

-- Finding Duplicates and near Duplicates.

-- SELECT DISTINCT "category" FROM transactions;
-- SELECT DISTINCT "payment_method" FROM transactions;
-- SELECT DISTINCT "location" FROM transactions;

-- None Found

-- Cross Validating Date-Time
SELECT 
  MIN("transaction_date") AS earliest, 
  MAX("transaction_date") AS latest 
FROM transactions;

--  Transactions Table Cleaning Report

-- - Renamed columns to snake_case for cleaner usage
-- - Trimmed all string values
-- - Checked Anomalies and Outliers
-- - Replaced nulls in Item with 'Unknown'
-- - Replaced nulls in Price Per Unit with mean
-- - Replaced nulls in Quantity with mean
-- - Replaced nulls in Total Spent with median
-- - Left Discount Applied nulls as it is
-- - Verified duplicates and near-duplicates

-- - Cross Validated Date-Time
