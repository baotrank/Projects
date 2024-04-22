-- Initial observation and understanding of the dataset
select * from ..melb_housing;

-----------------------------------------------------------------------------------------------------------------
--Standardizing the date format by removing the time at the end
--Rename the column name from "Date" (ambiguous) to SaleDate (the exact date the house was sold)

ALTER TABLE ..melb_housing
ADD SaleDate Date;

UPDATE ..melb_housing
SET SaleDate = CONVERT(date,Date);

----------------------------------------------------------------------------------------------------------------
-- Handling missing values in (null rows) in the following columns: Car, Buiding, YearBuilt & Council 
-- Count of null values in each of the aforementioned columns:
-- Car: 62, Buidling: 6.450, and YearBuilt: 5.375 null values

-- Car column: replacing null values with 0

UPDATE ..melb_housing
SET Car = 0
where Car IS NULL;

-- Building column: 6450/23580 rows (~47.5%) contain null values - which potentially affect later analysis.
--> I decide to divide data into 2 groups: those with and without Building Area information to later re-check if this variable affects the housing price in Mel.
-- The same logic would apply for YearBuilt column

ALTER TABLE ..melb_housing
ADD BuildingArea_status nvarchar(255);

UPDATE ..melb_housing
SET BuildingArea_status = 
(
	CASE
		WHEN BuildingArea IS NULL THEN 'No'
		ELSE 'Yes'
	END 
);

-- YearBuilt
ALTER TABLE ..melb_housing
ADD YearBuilt_status nvarchar(255);

UPDATE ..melb_housing
SET YearBuilt_status = 
(
	CASE
		WHEN YearBuilt IS NULL THEN 'No'
		ELSE 'Yes'
	END 
);


-----------------------------------------------------------------------------------------------------------------
-- Standardizing the data by replacing abbreviations to improve readability and the clarity of the data
-- Columns to work on : Type and Method

--Type
UPDATE ..melb_housing
SET Type = 'House'
WHERE Type = 'h';

UPDATE ..melb_housing
SET Type = 'Townhouse'
WHERE Type = 't';

UPDATE ..melb_housing
SET Type = 'Unit'
WHERE Type = 'u';

-- Method
UPDATE ..melb_housing
SET Method = 'Passed In'
WHERE Method = 'PI';

UPDATE ..melb_housing
SET Method = 'Sold'
WHERE Method = 'S';

UPDATE ..melb_housing
SET Method = 'Sold After Auction'
WHERE Method = 'SA';

UPDATE ..melb_housing
SET Method = 'Sold Prior'
WHERE Method = 'SP';

UPDATE ..melb_housing
SET Method = 'Vendor Bid'
WHERE Method = 'VB';

-----------------------------------------------------------------------------------------------------------------
-- Deleting unused columns
-- I use SaleDate, BuildingArea_status and YearBuilt_status as substitutes for deleted columns

ALTER TABLE ..melb_housing
DROP COLUMN Date, BuildingArea, YearBuilt;

-----------------------------------------------------------------------------------------------------------------
-- Proper case-conversion: capitalizing first letters in SellerG that are still in lowercase	
SELECT 
CONCAT(UPPER(LEFT(SellerG, 1)), LOWER(RIGHT(SellerG, LEN(SellerG) - 1))) AS RealEstate_Agent
FROM ..melb_housing;