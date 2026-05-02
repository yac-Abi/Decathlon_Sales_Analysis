CREATE DATABASE Decathlon;
USE Decathlon;

/* 
Data was imported with all columns in text format. 
We need to restore the original data types for specific columns.
*/

/* 
Step 1: Standardize Date Format (YYYY-MM-DD)
The source Date column is in French format (DD/MM/YYYY); we need to convert it:
*/

-- a. Create the new column with DATE type
ALTER TABLE data2022 ADD SaleDateConverted DATE;
 
-- b. Temporarily disable safe update mode (to allow bulk updates)
SET 
	SQL_SAFE_UPDATES = 0;

-- c. Run the date conversion logic
UPDATE 
	data2022 
SET 
	SaleDateConverted = STR_TO_DATE(Date_de_commande, '%d/%m/%Y');

-- d. Re enable safe update mode
SET 
	SQL_SAFE_UPDATES = 1;

-- e. Verify the conversion results
SELECT 
	Date_de_commande, 
    SaleDateConverted 
FROM 
	data2022 
LIMIT 5;



/* STEP 2: Pre Conversion Cleaning (Data Preparation)
-- Before restoring numerical formats (INT/DECIMAL), we clean empty cells, 
-- remove extra spaces, and replace commas with dots.
*/

SET 
	SQL_SAFE_UPDATES = 0;

UPDATE 
	data2022 
SET 
    -- Replace commas with dots AND remove leading/trailing spaces (TRIM)
    -- NULLIF converts empty strings '' into true NULLs to prevent casting errors
    Prix = NULLIF(TRIM(REPLACE(Prix, ',', '.')), ''),
    CA = NULLIF(TRIM(REPLACE(CA, ',', '.')), ''),
    Benefice = NULLIF(TRIM(REPLACE(Benefice, ',', '.')), ''),
    Quantite = NULLIF(TRIM(Quantite), '');

-- For the Data Integrity: we ensure no non-numeric characters remain in numerical columns
UPDATE data2022 SET Prix = NULL WHERE Prix REGEXP '[^0-9.]';
UPDATE data2022 SET CA = NULL WHERE CA REGEXP '[^0-9.]';
UPDATE data2022 SET Benefice = NULL WHERE Benefice REGEXP '[^0-9.]';
UPDATE data2022 SET Quantite = NULL WHERE Quantite REGEXP '[^0-9]';

SET 
	SQL_SAFE_UPDATES = 1;

-- Verify cleaning results
SELECT 
	Prix,
    CA,
    Benefice
FROM
	data2022
LIMIT 5;


/* 
   STEP 3: Final Casting (Data Type Modification)
   Now that columns no longer contain empty strings (only numeric values or NULLs), 
   we officially update their data types:
*/

ALTER TABLE data2022 
    MODIFY COLUMN Quantite INT,
    MODIFY COLUMN Prix DECIMAL(10,2),
    MODIFY COLUMN CA DECIMAL(10,2),
    MODIFY COLUMN Benefice DECIMAL(10,2);

-- Final verification of data types and values
SELECT SaleDateConverted, Quantite, Prix, CA, Benefice 
FROM data2022 
LIMIT 10;


-- Calculate Total Revenue for 2022.
SELECT
	SUM(CA) AS Total_Revenue
FROM
	data2022;
    
-- Calculate Total Profit for 2022.
SELECT
	SUM(Benefice) AS Total_Profit
FROM
	data2022;
    
-- Calculate Total Units Sold.
SELECT
	SUM(Quantite) AS Total_Units_Sold
FROM
	data2022;
