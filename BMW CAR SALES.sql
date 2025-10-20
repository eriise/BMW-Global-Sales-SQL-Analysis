--  CREATE DATABASE
CREATE DATABASE BMW_SALES;


--  CHECK TABLE
SELECT * 
FROM BMW_sales_dataset;


--  TOTAL REVENUE PER REGION
SELECT region, SUM(Price_USD * sales_volume) AS total_revenue
FROM BMW_sales_dataset
GROUP BY region
ORDER BY SUM(Price_USD * sales_volume);


--  TOP 10 AUTOMATIC CARS BY HIGHEST TOTAL SALES
SELECT TOP 10 Year, SUM(Sales_Volume) AS Total_sold
FROM BMW_sales_dataset
WHERE Transmission = 'Automatic'
GROUP BY Year
ORDER BY SUM(Sales_Volume) DESC;


-- YEARS WITH THE HIGHEST REVENUE
SELECT TOP 10 Year, SUM(Price_USD * sales_volume) AS total_revenue
FROM BMW_sales_dataset
GROUP BY Year
ORDER BY SUM(Price_USD * sales_volume) DESC;


-- REGION REVENUE % CONTRIBUTION
SELECT region,
       ROUND(SUM(price_usd * sales_volume) * 100.0 /
             (SELECT SUM(price_usd * sales_volume) FROM BMW_sales_dataset), 2) AS revenue_share_pct
FROM BMW_sales_dataset
GROUP BY region
ORDER BY revenue_share_pct DESC;


-- AVERAGE PRICE PER ENGINE SIZE
SELECT
    CASE
        WHEN ENGINE_SIZE_L < 2.0 THEN 'SMALL ENGINE'
        WHEN ENGINE_SIZE_L BETWEEN 2.0 AND 3.0 THEN 'MEDIUM ENGINE'
        ELSE 'LARGE ENGINE'
    END AS ENGINE_SIZING,
    AVG(Price_USD) AS AV_PRICE
FROM BMW_sales_dataset
GROUP BY CASE
    WHEN ENGINE_SIZE_L < 2.0 THEN 'SMALL ENGINE'
    WHEN ENGINE_SIZE_L BETWEEN 2.0 AND 3.0 THEN 'MEDIUM ENGINE'
    ELSE 'LARGE ENGINE'
END
ORDER BY SUM(Price_USD) DESC;


-- TOP 10 REGION AND MODEL SOLD (BY REVENUE)
SELECT TOP 10 region, model,
       SUM(Price_USD * sales_volume) AS total_revenue
FROM BMW_sales_dataset
GROUP BY region, model
ORDER BY SUM(Price_USD * sales_volume) DESC;


-- TOP FUEL TYPE BY REGION
SELECT region, fuel_type
FROM (
    SELECT region, fuel_type, SUM(sales_volume) AS total_sales_volume,
           RANK() OVER(PARTITION BY region ORDER BY SUM(sales_volume) DESC) AS regional
    FROM BMW_sales_dataset
    GROUP BY region, fuel_type
) ranked
WHERE regional = 1;


-- TOP 3 BEST SELLING COLORS (BY SALES CLASSIFICATION)
SELECT sales_classification, color
FROM (
    SELECT sales_classification, color, SUM(sales_volume) AS total_sold,
           RANK() OVER(PARTITION BY sales_classification ORDER BY SUM(sales_volume) DESC) AS color_rank
    FROM BMW_sales_dataset
    GROUP BY sales_classification, color
) ranked
WHERE color_rank <= 3;


--  TOP COLOUR SOLD EVERY YEAR
SELECT Color, Year, total_revenue
FROM (
    SELECT Color, Year,
           SUM(Price_USD * sales_volume) AS total_revenue,
           RANK() OVER(PARTITION BY Year ORDER BY SUM(sales_volume * price_usd) DESC) AS RANKED_COLOUR
    FROM BMW_sales_dataset
    GROUP BY Color, Year
) ranks
WHERE RANKED_COLOUR = 1;


--  TOP COLOURS SOLD (OVERALL)
SELECT TOP 10 Color, Year,
       SUM(Price_USD * sales_volume) AS total_revenue
FROM BMW_sales_dataset
GROUP BY Color, Year
ORDER BY SUM(Price_USD * sales_volume) DESC;


-- TOP MODEL WITH THE HIGHEST REVENUE PER REGION
SELECT region, model, total_revenue
FROM (
  SELECT region, model,
         SUM(sales_volume * price_usd) AS total_revenue,
         RANK() OVER (PARTITION BY region ORDER BY SUM(sales_volume * price_usd) DESC) AS rank_in_region
  FROM BMW_sales_dataset
  GROUP BY region, model
) ranked
WHERE rank_in_region = 1;


-- MODEL-YEAR MOST SOLD PER REGION
SELECT region, model, Year, TOTAL_SALES
FROM (
  SELECT region, model, Year,
         SUM(sales_volume) AS TOTAL_SALES,
         RANK() OVER(PARTITION BY region ORDER BY SUM(sales_volume) DESC) AS rank_in_region
  FROM BMW_sales_dataset
  GROUP BY region, model, Year
) ranked
WHERE rank_in_region = 1;


-- YEAR-OVER-YEAR % REVENUE CHANGE
SELECT year,
       SUM(sales_volume) AS total_sales,
       LAG(SUM(sales_volume)) OVER(ORDER BY year) AS prev_sales,
       ROUND((SUM(sales_volume) - LAG(SUM(sales_volume)) OVER(ORDER BY year)) * 100.0 /
             LAG(SUM(sales_volume)) OVER(ORDER BY year), 2) AS yoy_change_pct
FROM BMW_sales_dataset
GROUP BY year
ORDER BY year;
