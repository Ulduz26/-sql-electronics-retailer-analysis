/* ============================================================
   Global Electronics Retailer - Data Cleaning
   Fixes issues found in Products after import:
     1. Unit_Cost_USD / Unit_Price_USD were imported as raw text
        (e.g. '$158.00 ') and needed cleaning + type conversion.
     2. 9 products with a comma inside Product_Name caused a
        column-shift during import, corrupting their Cost/Price
        values. Fixed manually using the true values from the
        original CSV.
   ============================================================ */

-- --------------------------------------------------------------
-- Step 1: Fix 9 rows where columns shifted due to commas
--         inside Product_Name during import
-- --------------------------------------------------------------
UPDATE Products SET Unit_Cost_USD = '$72.66 ', Unit_Price_USD = '$158.00 ' WHERE ProductKey = 656;
UPDATE Products SET Unit_Cost_USD = '$73.12 ', Unit_Price_USD = '$159.00 ' WHERE ProductKey = 660;
UPDATE Products SET Unit_Cost_USD = '$72.66 ', Unit_Price_USD = '$158.00 ' WHERE ProductKey = 685;
UPDATE Products SET Unit_Cost_USD = '$73.12 ', Unit_Price_USD = '$159.00 ' WHERE ProductKey = 689;
UPDATE Products SET Unit_Cost_USD = '$72.66 ', Unit_Price_USD = '$158.00 ' WHERE ProductKey = 714;
UPDATE Products SET Unit_Cost_USD = '$73.12 ', Unit_Price_USD = '$159.00 ' WHERE ProductKey = 718;
UPDATE Products SET Unit_Cost_USD = '$72.66 ', Unit_Price_USD = '$158.00 ' WHERE ProductKey = 733;
UPDATE Products SET Unit_Cost_USD = '$73.12 ', Unit_Price_USD = '$159.00 ' WHERE ProductKey = 737;
UPDATE Products SET Unit_Cost_USD = '$16.31 ', Unit_Price_USD = '$32.00 '  WHERE ProductKey = 1826;

-- Verify: should return 9 rows if all fixed correctly
SELECT ProductKey, Unit_Cost_USD, Unit_Price_USD
FROM Products
WHERE ProductKey IN (656, 660, 685, 689, 714, 718, 733, 737, 1826);


-- --------------------------------------------------------------
-- Step 2: Strip '$', ',' and stray '"' characters from the
--         price columns, leaving clean numeric-looking text
-- --------------------------------------------------------------
UPDATE Products
SET Unit_Price_USD = TRIM(REPLACE(REPLACE(REPLACE(Unit_Price_USD, ',', ''), '$', ''), '"', ''));

UPDATE Products
SET Unit_Cost_USD = TRIM(REPLACE(REPLACE(REPLACE(Unit_Cost_USD, ',', ''), '$', ''), '"', ''));

-- Verify no values fail conversion (should return 0 rows for each)
SELECT ProductKey, Unit_Price_USD
FROM Products
WHERE TRY_CAST(Unit_Price_USD AS DECIMAL(7,2)) IS NULL;

SELECT ProductKey, Unit_Cost_USD
FROM Products
WHERE TRY_CAST(Unit_Cost_USD AS DECIMAL(7,2)) IS NULL;


-- --------------------------------------------------------------
-- Step 3: Convert column types from NVARCHAR to DECIMAL(7,2)
--         now that values are clean text ('158.00' etc.)
--         Precision 7, scale 2 comfortably fits the max price
--         seen in the data (3199.99).
-- --------------------------------------------------------------
ALTER TABLE Products
ALTER COLUMN Unit_Price_USD DECIMAL(7,2);

ALTER TABLE Products
ALTER COLUMN Unit_Cost_USD DECIMAL(7,2);

-- Final check: columns should now be numeric (right-aligned, no quotes)
SELECT ProductKey, Unit_Cost_USD, Unit_Price_USD FROM Products;
