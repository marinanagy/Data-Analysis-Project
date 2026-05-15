
USE BMW_Sales_Project;

                                                             -------------------------------------
                                                                          --Analysis
                                                             -------------------------------------


 -------------------------------------
               --KPI--
 -------------------------------------
 
         -- Total Revenue

 SELECT 
SUM(Revenue) AS Total_Revenue
FROM Fact_Sales;

        -- Total Units Sold

SELECT 
SUM(Units_Sold) AS Total_Units_Sold
FROM Fact_Sales;

           -- Top Segment

SELECT TOP 1
M.Segment,
SUM(F.Revenue) AS Total_Revenue
FROM Fact_Sales F
JOIN Dim_Model M
ON F.Model_Code = M.Model_Code
GROUP BY M.Segment
ORDER BY Total_Revenue DESC;

           -- Top Country

SELECT TOP 1
C.CountryName,
SUM(F.Revenue) AS Total_Revenue
FROM Fact_Sales F
JOIN Dim_Country C
ON F.CountryCode = C.CountryCode
GROUP BY C.CountryName
ORDER BY Total_Revenue DESC;


 -------------------------------------
    --Sales Performance Insights--
 -------------------------------------

-- TOP 5 MODEL REVENUE

SELECT TOP 5
    M.Model,
    SUM(F.Revenue) AS Total_Revenue
FROM Fact_Sales F join Dim_Model M 
ON M.Model_Code = F.Model_Code
GROUP BY M.Model
ORDER BY Total_Revenue DESC;

-- TOTAL REVENUE PER YEAR

SELECT TOP 5
    D.Year,
SUM(F.Revenue) AS Total_Revenue
FROM Fact_Sales F join Dim_Date D
ON D.DateKey = F.DateKey
GROUP BY D.Year
ORDER BY SUM (F.Revenue) DESC;


 -------------------------------------
    --Customer / Market Insights --
 -------------------------------------

 -- UNITS SOLD BY ENGINE_TYPE
 
SELECT 
    M.engine_type,
    SUM (F.units_sold)as Total_Units_sold
FROM Fact_Sales F join Dim_Model M
ON M.Model_Code = F.Model_Code
GROUP BY M.engine_type
ORDER BY SUM (F.units_sold) DESC;


--TOP MODEL PER COUNTRY

WITH Model_Revenue AS (
    SELECT
        C.CountryName,
        M.Model,
        SUM(F.Revenue) AS Total_Revenue,
        ROW_NUMBER() OVER (
            PARTITION BY C.CountryName
            ORDER BY SUM(F.Revenue) DESC
        ) AS Ranking
    FROM Fact_Sales F

    JOIN Dim_Country C
    ON F.CountryCode = C.CountryCode

    JOIN Dim_Model M
    ON F.Model_Code = M.Model_Code

    GROUP BY
        C.CountryName,
        M.Model
)

SELECT
    CountryName,
    Model,
    CAST(Total_Revenue AS INT) AS Total_Revenue
FROM Model_Revenue
WHERE Ranking = 1
ORDER BY Total_Revenue DESC;

 -------------------------------------
      -- Marketing vs. Revenue --
 -------------------------------------
 SELECT
    D.Year,
    SUM(F.Marketing_Spend_USD) AS Marketing_Spend,
    SUM(F.Revenue) AS Revenue
FROM Fact_Sales F
JOIN Dim_Date D
ON F.DateKey = D.DateKey
GROUP BY D.Year
ORDER BY D.Year;


WITH Data AS (
    SELECT
        D.Year,
        CAST(SUM(F.Marketing_Spend_USD) AS FLOAT) AS Marketing_Spend,
        CAST(SUM(F.Revenue) AS FLOAT) AS Revenue
    FROM Fact_Sales F
    JOIN Dim_Date D
        ON F.DateKey = D.DateKey
    GROUP BY D.Year
)

SELECT 
(
    COUNT(*) * SUM(Marketing_Spend * Revenue)
    - SUM(Marketing_Spend) * SUM(Revenue)
)
/
NULLIF(
SQRT(
    (
        COUNT(*) * SUM(POWER(Marketing_Spend, 2))
        - POWER(SUM(Marketing_Spend), 2)
    )
    *
    (
        COUNT(*) * SUM(POWER(Revenue, 2))
        - POWER(SUM(Revenue), 2)
    )
),0
) AS Correlation
FROM Data;


