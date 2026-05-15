
--CREATING DATABASE 

CREATE DATABASE BMW_Sales_Project;
USE BMW_Sales_Project;

--IMPORT FILE 

---------------------------------
     --(Data Exploration)
---------------------------------

-- How many rows 

SELECT COUNT(*) 
FROM BMW_Sales;

--VIWE ALL COLUMNS

SELECT * 
FROM BMW_Sales;

--SHOW COLUMNS CONTENT

SELECT DISTINCT YEAR
FROM BMW_Sales
ORDER BY YEAR;

SELECT DISTINCT COUNTRY
FROM BMW_Sales;

SELECT DISTINCT MONTH
FROM BMW_Sales
ORDER BY MONTH;

SELECT DISTINCT MODEL
FROM BMW_Sales;

SELECT DISTINCT SEGMENT
FROM BMW_Sales;

SELECT DISTINCT ENGINE_TYPE
FROM BMW_Sales;

---------------------------------
       --(Data Cleaning)
---------------------------------

--Check Nulls 

SELECT *
FROM BMW_Sales
WHERE
    year IS NULL
    OR month IS NULL
    OR country IS NULL
    OR model IS NULL
    OR segment IS NULL
    OR engine_type IS NULL
    OR price_usd IS NULL
    OR marketing_spend_usd IS NULL
    OR dealership_count IS NULL
    OR competition_index IS NULL
    OR Units_Sold IS NULL;

--Check DUP.

SELECT year,month,country,model,segment,engine_type,price_usd,COUNT(*)
FROM BMW_Sales
GROUP By year,month,country,model,segment,engine_type,price_usd
HAVING COUNT(*) > 1;

--Check (-) / (WRONG VALUES)

SELECT *
FROM BMW_Sales
WHERE Price_Usd <= 0;

SELECT *
FROM BMW_Sales
WHERE Month NOT BETWEEN 1 AND 12;
-------------------------------------------------------
-- CREATE REVENUE COLUMNS

SELECT *,Price_Usd * Units_Sold AS Revenue
FROM BMW_Sales;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------
                                                          ---(Data Modeling)---
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
 
 --------------------------------------------
-- DIM_DATE
---------------------------------------------
CREATE TABLE Dim_Date (
    DateKey INT PRIMARY KEY,
    Year INT,
    Month INT
);
---------------------------------------------
-- INSERT INTO Dim_Date
---------------------------------------------
INSERT INTO Dim_Date(DateKey, Year, Month)
SELECT DISTINCT
    Year * 100 + Month AS DateKey,
    Year,
    Month
FROM BMW_Sales;
---------------------------------------------
-- VIEW Dim_Date
---------------------------------------------
SELECT *
FROM Dim_Date;

---------------------------------------------
-- DIM_COUNTRY
---------------------------------------------
CREATE TABLE Dim_Country (
    CountryCode CHAR(2) PRIMARY KEY,
    CountryName VARCHAR(100)
);
---------------------------------------------
-- INSERT INTO Dim_Country
---------------------------------------------
INSERT INTO Dim_Country(CountryCode, CountryName)
SELECT DISTINCT
CASE 
    WHEN Country = 'USA' THEN 'US'
    WHEN Country = 'Australia' THEN 'AU'
    WHEN Country = 'Brazil' THEN 'BR'
    WHEN Country = 'China' THEN 'CN'
    WHEN Country = 'India' THEN 'IN'
    WHEN Country = 'UK' THEN 'UK'
    WHEN Country = 'Canada' THEN 'CA'
    WHEN Country = 'Germany' THEN 'DE'
    WHEN Country = 'France' THEN 'FR'
    WHEN Country = 'Japan' THEN 'JP'
END,
Country
FROM BMW_Sales;
---------------------------------------------
-- VIEW Dim_Country
---------------------------------------------
SELECT *
FROM Dim_Country;

---------------------------------------------
-- DIM_MODEL
---------------------------------------------
CREATE TABLE Dim_Model (

    Model_Code VARCHAR(50) PRIMARY KEY,
    Model VARCHAR(100),
    Segment VARCHAR(100),
    Engine_Type VARCHAR(100)
);
---------------------------------------------
-- INSERT INTO Dim_Model
---------------------------------------------
INSERT INTO Dim_Model
(Model_Code, Model, Segment, Engine_Type)
SELECT DISTINCT
UPPER(
    REPLACE(Model, ' ', '_')
    + '_' +
    LEFT(Segment, 2)
    + '_' +
    LEFT(Engine_Type, 2)
) AS Model_Code,
Model,
Segment,
Engine_Type
FROM BMW_Sales;
---------------------------------------------
-- VIEW Dim_Model
---------------------------------------------
SELECT *
FROM Dim_Model;
---------------------------------------------
-- FACT_SALES
---------------------------------------------
CREATE TABLE Fact_Sales (
    Sales_ID INT IDENTITY PRIMARY KEY,
    DateKey INT,
    CountryCode CHAR(2),
    Model_Code VARCHAR(50),
    Units_Sold INT,
    Price_USD DECIMAL(10,2),
    Marketing_Spend_USD DECIMAL(12,2),
    Revenue DECIMAL(15,2),
    Competition_Index TINYINT,
    Dealership_Count SMALLINT,

    CONSTRAINT FK_Date
    FOREIGN KEY (DateKey)
    REFERENCES Dim_Date(DateKey),

    CONSTRAINT FK_Country
    FOREIGN KEY (CountryCode)
    REFERENCES Dim_Country(CountryCode),

    CONSTRAINT FK_Model
    FOREIGN KEY (Model_Code)
    REFERENCES Dim_Model(Model_Code)
);

---------------------------------------------
-- INSERT INTO Fact_Sales
---------------------------------------------
INSERT INTO Fact_Sales (
    DateKey,
    CountryCode,
    Model_Code,
    Units_Sold,
    Price_USD,
    Marketing_Spend_USD,
    Revenue,
    Competition_Index,
    Dealership_Count
)

SELECT
    d.DateKey,
    c.CountryCode,
    m.Model_Code,
    s.Units_Sold,
    s.Price_USD,
    s.Marketing_Spend_USD,
    s.Price_USD * s.Units_Sold AS Revenue,
    s.Competition_Index,
    s.Dealership_Count

FROM BMW_Sales s

JOIN Dim_Date d
ON s.Year = d.Year
AND s.Month = d.Month

JOIN Dim_Country c
ON s.Country = c.CountryName

JOIN Dim_Model m
ON s.Model = m.Model
AND s.Engine_Type = m.Engine_Type
AND s.Segment = m.Segment
---------------------------------------------
-- VIEW FACT TABLE
---------------------------------------------
SELECT *
FROM Fact_Sales;

SELECT COUNT(*)
FROM Fact_Sales;
