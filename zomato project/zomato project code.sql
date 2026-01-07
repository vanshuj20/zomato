create Database Zomato_db;
use zomato_db;
select count(*) from menu;


-- USERS TABLE BASE CLEANING 4 STEP;

DESC users;
SELECT * FROM users LIMIT 20;

ALTER TABLE users
DROP COLUMN MyUnknownColumn;

ALTER TABLE users
MODIFY user_id INT NOT NULL;

ALTER TABLE users
ADD PRIMARY KEY (user_id);

UPDATE users
SET
  name = TRIM(name),
  email = TRIM(email),
  Gender = TRIM(Gender),
  `Marital Status` = TRIM(`Marital Status`),
  Occupation = TRIM(Occupation),
  `Monthly Income` = TRIM(`Monthly Income`),
  `Educational Qualifications` = TRIM(`Educational Qualifications`)
WHERE user_id IS NOT NULL
LIMIT 1000000;

UPDATE users
SET Gender =
CASE
  WHEN LOWER(Gender) IN ('m','male') THEN 'Male'
  WHEN LOWER(Gender) IN ('f','female') THEN 'Female'
  ELSE 'Other'
END
WHERE user_id IS NOT NULL
LIMIT 1000000;

UPDATE users
SET `Marital Status` =
CASE
  WHEN LOWER(`Marital Status`) LIKE '%single%' THEN 'Single'
  WHEN LOWER(`Marital Status`) LIKE '%married%' THEN 'Married'
  ELSE 'Unknown'
END
WHERE user_id IS NOT NULL
LIMIT 1000000;

UPDATE users
SET Occupation =
CASE
  WHEN LOWER(Occupation) LIKE '%student%' THEN 'Student'
  WHEN LOWER(Occupation) LIKE '%self%' THEN 'Self Employed'
  WHEN LOWER(Occupation) LIKE '%employee%' THEN 'Employee'
  ELSE Occupation
END
WHERE user_id IS NOT NULL
LIMIT 1000000;

UPDATE users
SET `Educational Qualifications` =
CASE
  WHEN LOWER(`Educational Qualifications`) LIKE '%ph%' THEN 'PhD'
  WHEN LOWER(`Educational Qualifications`) LIKE '%post%' THEN 'Post Graduate'
  WHEN LOWER(`Educational Qualifications`) LIKE '%graduate%' THEN 'Graduate'
  ELSE 'Other'
END
WHERE user_id IS NOT NULL
limit 1000000;

ALTER TABLE users
ADD COLUMN monthly_income_int INT;

UPDATE users
SET monthly_income_int =
CASE
  WHEN `Monthly Income` LIKE 'No%' THEN 0
  WHEN `Monthly Income` LIKE 'Below%' THEN 10000
  WHEN `Monthly Income` LIKE '%25001%' THEN 37500
  WHEN `Monthly Income` LIKE 'More%' THEN 60000
  ELSE NULL
END
WHERE user_id IS NOT NULL
limit 1000000;

UPDATE users
SET Age = NULL
WHERE (Age < 0 OR Age > 100)
AND user_id IS NOT NULL
limit 1000000;

UPDATE users
SET `Family size` = NULL
WHERE (`Family size` <= 0 OR `Family size` > 20)
AND user_id IS NOT NULL
limit 1000000;

ALTER TABLE users
MODIFY Age INT,
MODIFY Gender VARCHAR(10),
MODIFY `Marital Status` VARCHAR(20),
MODIFY Occupation VARCHAR(50),
MODIFY `Educational Qualifications` VARCHAR(50),
MODIFY `Family size` INT;

-- ✅ USERS TABLE – FINAL STATUS

-- ✔ Junk column removed
-- ✔ PK applied
-- ✔ No duplicate users
-- ✔ Categorical data standardized
-- ✔ Income numeric & analytics-ready
-- ✔ Safe-mode compliant SQL

-- RESTAURANT TABLE CLEAN;

DESC restaurant;
SELECT * FROM restaurant ;

ALTER TABLE restaurant
DROP COLUMN MyUnknownColumn;

ALTER TABLE restaurant
ADD COLUMN restaurant_pk INT;

SET @r = 0;

UPDATE restaurant
SET restaurant_pk = (@r := @r + 1)
ORDER BY id
LIMIT 1000000;

ALTER TABLE restaurant
MODIFY restaurant_pk INT NOT NULL;

ALTER TABLE restaurant
ADD PRIMARY KEY (restaurant_pk);

UPDATE restaurant
SET
  name = TRIM(name),
  city = TRIM(city),
  cuisine = TRIM(cuisine),
  address = TRIM(address)
WHERE restaurant_pk IS NOT NULL
LIMIT 1000000;

UPDATE restaurant
SET city = CONCAT(UPPER(LEFT(city,1)), LOWER(SUBSTRING(city,2)))
WHERE restaurant_pk IS NOT NULL
LIMIT 1000000;

UPDATE restaurant
SET rating = NULL
WHERE rating IN ('--','NEW','')
LIMIT 1000000;

UPDATE restaurant
SET rating = NULL
WHERE rating IS NULL
   OR rating = ''
   OR rating IN ('NEW','--')
   OR rating NOT REGEXP '^[0-9]+(\\.[0-9]+)?$'
limit 1000000;

ALTER TABLE restaurant
MODIFY rating DECIMAL(2,1);


UPDATE restaurant
SET rating_count = NULL
WHERE rating_count IS NULL
   OR rating_count = ''
   OR rating_count NOT REGEXP '^[0-9]+$'
LIMIT 1000000;

ALTER TABLE restaurant
MODIFY rating_count INT;

UPDATE restaurant
SET cost = REPLACE(cost, ',', '')
WHERE cost IS NOT NULL
LIMIT 1000000;

UPDATE restaurant
SET cost = NULL
WHERE cost NOT REGEXP '^[0-9]+$'
LIMIT 1000000;

ALTER TABLE restaurant
MODIFY cost INT;

UPDATE restaurant
SET name = 'Unknown Restaurant'
WHERE name IS NULL
LIMIT 1000000;

UPDATE restaurant
SET city = 'Unknown'
WHERE city IS NULL
LIMIT 1000000;

UPDATE restaurant
SET cuisine = 'Not Specified'
WHERE cuisine IS NULL
LIMIT 1000000;

UPDATE restaurant
SET address = 'Address Not Available'
WHERE address IS NULL
LIMIT 1000000;


ALTER TABLE restaurant
MODIFY name TEXT NOT NULL;

ALTER TABLE restaurant
MODIFY city TEXT NOT NULL;

-- ORDERS TABLE CLEANING

-- ====================================================
-- 1. INSPECTION & SETUP
-- ====================================================

-- Check current state
DESC orders;
SELECT * FROM orders LIMIT 20;

-- Drop Junk Column
ALTER TABLE orders
DROP COLUMN MyUnknownColumn;

-- Add Surrogate Primary Key (User Style)
ALTER TABLE orders
ADD COLUMN order_pk INT;

SET @r = 0;

UPDATE orders
SET order_pk = (@r := @r + 1)
ORDER BY order_date -- Keeping original order somewhat sorted if possible, or just arbitrary
LIMIT 1000000;

ALTER TABLE orders
MODIFY order_pk INT NOT NULL;

ALTER TABLE orders
ADD PRIMARY KEY (order_pk);


-- ====================================================
-- 2. STRING CLEANING (Currency)
-- ====================================================

-- Clean Currency (Remove Newlines and Spaces)
UPDATE orders
SET currency = TRIM(REPLACE(currency, '\n', ''))
WHERE order_pk IS NOT NULL
LIMIT 1000000;

-- Standardize Currency
UPDATE orders
SET currency = 'INR'
WHERE currency LIKE 'INR%' OR currency = ''
LIMIT 1000000;

UPDATE orders
SET currency = 'Unknown'
WHERE currency IS NULL
LIMIT 1000000;


-- ====================================================
-- 3. DATE CLEANING (order_date)
-- ====================================================

-- Set Junk Dates to NULL (e.g., 'mn466061')
UPDATE orders
SET order_date = NULL
WHERE order_date NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' -- Matches YYYY-MM-DD
LIMIT 1000000;

-- Convert Column Type
ALTER TABLE orders
MODIFY order_date DATE;


-- ====================================================
-- 4. NUMERIC CLEANING (Sales, User ID, Restaurant ID)
-- ====================================================

-- Clean sales_qty
UPDATE orders
SET sales_qty = NULL
WHERE sales_qty NOT REGEXP '^[0-9]+$'
LIMIT 1000000;

ALTER TABLE orders
MODIFY sales_qty INT;

-- Clean sales_amount (Handle decimals if any, remove commas)
UPDATE orders
SET sales_amount = REPLACE(sales_amount, ',', '')
WHERE sales_amount IS NOT NULL
LIMIT 1000000;

UPDATE orders
SET sales_amount = NULL
WHERE sales_amount NOT REGEXP '^[0-9]+(\\.[0-9]+)?$'
LIMIT 1000000;

ALTER TABLE orders
MODIFY sales_amount DECIMAL(10,2);

-- Clean user_id (Remove non-numeric junk)
UPDATE orders
SET user_id = NULL
WHERE user_id NOT REGEXP '^[0-9]+$'
LIMIT 1000000;

ALTER TABLE orders
MODIFY user_id INT;

-- Clean r_id (Remove non-numeric junk)
UPDATE orders
SET r_id = NULL
WHERE r_id NOT REGEXP '^[0-9]+$'
LIMIT 1000000;

ALTER TABLE orders
MODIFY r_id INT;


-- ====================================================
-- 5. HANDLING NULLS / ORPHANS
-- ====================================================

-- Remove rows where Order Date is missing (Critical Data)
-- (Optional: Depending on business rule, you might delete or keep)
-- DELETE FROM orders WHERE order_date IS NULL; 
-- For now, let's keep them but ensure we know they are invalid.

-- ====================================================
-- ✅ ORDERS TABLE – FINAL STATUS
-- ====================================================

-- ✔ Junk column (MyUnknownColumn) removed
-- ✔ PK (order_pk) applied using variable increment
-- ✔ Junk Dates ('mn466061') removed & converted to DATE type
-- ✔ Currency standardized ('INR\n' -> 'INR')
-- ✔ Sales & IDs converted to Numeric Types (INT/DECIMAL)
-- ✔ Safe-mode compliant SQL

-- ====================================================
-- 1. INSPECTION & SETUP
-- ====================================================

-- Check current state
DESC menu;
SELECT * FROM menu LIMIT 20;

-- Drop Junk Column
ALTER TABLE menu
DROP COLUMN MyUnknownColumn;

-- Add Surrogate Primary Key (Safety first)
ALTER TABLE menu
ADD COLUMN menu_pk INT;

SET @r = 0;

UPDATE menu
SET menu_pk = (@r := @r + 1)
ORDER BY menu_id -- Attempt to keep some order
LIMIT 1000000;

ALTER TABLE menu
MODIFY menu_pk INT NOT NULL;

ALTER TABLE menu
ADD PRIMARY KEY (menu_pk);


-- ====================================================
-- 2. CLEANING FOREIGN KEYS (r_id, f_id)
-- ====================================================

-- Clean r_id (Restaurant ID must be numeric)
UPDATE menu
SET r_id = NULL
WHERE r_id NOT REGEXP '^[0-9]+$'
LIMIT 1000000;

ALTER TABLE menu
MODIFY r_id INT;

-- Clean f_id (Food ID)
-- Remove obviously shifted values like 'Veg', 'Non-veg' or Dates
UPDATE menu
SET f_id = NULL
WHERE f_id IN ('Veg', 'Non-veg') 
   OR f_id LIKE '20%' -- Removing Dates (e.g. 2018-02-XX)
   OR f_id = ''
LIMIT 1000000;

ALTER TABLE menu
MODIFY f_id VARCHAR(50); -- Keep VARCHAR as f_id can be alphanumeric (e.g. fd1)


-- ====================================================
-- 3. CLEANING CUISINE (Shifted Data Handling)
-- ====================================================

-- Clean Strings
UPDATE menu
SET cuisine = TRIM(REPLACE(cuisine, '\n', ''))
WHERE cuisine IS NOT NULL
LIMIT 1000000;

-- Handle Shifted/Junk Data (Currency in Cuisine column)
UPDATE menu
SET cuisine = 'Not Specified'
WHERE cuisine LIKE '%INR%' 
   OR cuisine REGEXP '^[0-9]+$' -- Numbers in cuisine
   OR cuisine IS NULL 
   OR cuisine = ''
LIMIT 1000000;

-- Standardize Formatting (Title Case)
UPDATE menu
SET cuisine = CONCAT(UPPER(LEFT(cuisine,1)), LOWER(SUBSTRING(cuisine,2)))
WHERE cuisine != 'Not Specified'
LIMIT 1000000;


-- ====================================================
-- 4. CLEANING PRICE
-- ====================================================

-- Remove Commas if any
UPDATE menu
SET price = REPLACE(price, ',', '')
WHERE price IS NOT NULL
LIMIT 1000000;

-- Remove Non-Numeric Prices
UPDATE menu
SET price = NULL
WHERE price NOT REGEXP '^[0-9]+(\\.[0-9]+)?$'
LIMIT 1000000;

-- Convert to Decimal
ALTER TABLE menu
MODIFY price DECIMAL(10,2);

-- Handle Zero or Null Prices (Optional Logic: Default to 0.00)
UPDATE menu
SET price = 0.00
WHERE price IS NULL
LIMIT 1000000;


-- ====================================================
-- ✅ MENU TABLE – FINAL STATUS
-- ====================================================

-- ✔ Junk column (MyUnknownColumn) removed
-- ✔ PK (menu_pk) applied safely
-- ✔ Shifted data in 'Cuisine' (like 'INR') removed
-- ✔ 'Veg'/'Non-veg' removed from ID columns
-- ✔ Price standardized to DECIMAL
-- ✔ Safe-mode compliant SQL

-- ====================================================
-- 1. INSPECTION & SETUP
-- ====================================================

-- Check current state
DESC food;
SELECT * FROM food LIMIT 20;

-- Drop Junk Column
ALTER TABLE food
DROP COLUMN MyUnknownColumn;

-- Add Surrogate Primary Key (Safety first)
ALTER TABLE food
ADD COLUMN food_pk INT;

SET @r = 0;

UPDATE food
SET food_pk = (@r := @r + 1)
ORDER BY f_id -- Attempt to keep order
LIMIT 1000000;

ALTER TABLE food
MODIFY food_pk INT NOT NULL;

ALTER TABLE food
ADD PRIMARY KEY (food_pk);


-- ====================================================
-- 2. CLEANING FOOD ID (f_id)
-- ====================================================

-- Trim Whitespace
UPDATE food
SET f_id = TRIM(f_id)
WHERE f_id IS NOT NULL
LIMIT 1000000;

-- Identify & Remove Junk IDs (Dates or unexpected numbers)
-- Valid IDs look like 'fd1', 'fd2'. Junk looks like '2018-03-19' or '17514'.
UPDATE food
SET f_id = NULL
WHERE f_id LIKE '20%'  -- Starts with year 20xx
   OR f_id LIKE '19%' 
   OR f_id REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' -- Matches Date Format
LIMIT 1000000;


-- ====================================================
-- 3. CLEANING ITEM NAME
-- ====================================================

-- Trim Whitespace
UPDATE food
SET item = TRIM(item)
WHERE item IS NOT NULL
LIMIT 1000000;

-- Handle Shifted Junk (Numeric items like '3' or '12')
UPDATE food
SET item = 'Unknown Item'
WHERE item REGEXP '^[0-9]+$' -- Item name is just numbers
   OR item IS NULL 
   OR item = ''
LIMIT 1000000;


-- ====================================================
-- 4. CLEANING VEG / NON-VEG
-- ====================================================

-- Trim Whitespace
UPDATE food
SET veg_or_non_veg = TRIM(veg_or_non_veg)
WHERE veg_or_non_veg IS NOT NULL
LIMIT 1000000;

-- Standardize (Case formatting just in case)
UPDATE food
SET veg_or_non_veg = 'Veg'
WHERE veg_or_non_veg LIKE 'Veg%'
LIMIT 1000000;

UPDATE food
SET veg_or_non_veg = 'Non-veg'
WHERE veg_or_non_veg LIKE 'Non%'
LIMIT 1000000;

-- Handle Invalid Values (e.g. '3000' from shifted rows)
UPDATE food
SET veg_or_non_veg = 'Not Specified'
WHERE veg_or_non_veg NOT IN ('Veg', 'Non-veg')
   OR veg_or_non_veg IS NULL
LIMIT 1000000;


-- ====================================================
-- ✅ FOOD TABLE – FINAL STATUS
-- ====================================================

-- ✔ Junk column (MyUnknownColumn) removed
-- ✔ PK (food_pk) applied safely
-- ✔ Junk IDs (Dates) set to NULL
-- ✔ Item names cleaned (Numeric junk -> 'Unknown Item')
-- ✔ Veg/Non-veg standardized and validated
-- ✔ Safe-mode compliant SQL

SELECT * FROM USERS;
SELECT * FROM RESTAURANT;
SELECT * FROM ORDERS;
SELECT * FROM MENU;
SELECT * FROM FOOD;

use zomato_db;

-- 1. What are the top 10 restaurants by total sales amount? 
SELECT 
    r.name AS Restaurant_Name, 
    SUM(o.sales_amount) AS Total_Revenue
FROM orders o
JOIN restaurant r ON o.r_id = r.id
GROUP BY r.name
ORDER BY Total_Revenue DESC
LIMIT 10;


-- 2. What is the average rating and total rating count for restaurants in the 
-- top 20 cities? 
SELECT 
    city, 
    COUNT(restaurant_pk) AS Total_Restaurants, 
    ROUND(AVG(rating), 2) AS Avg_Rating, 
    SUM(rating_count) AS Total_Rating_Count
FROM restaurant
GROUP BY city
ORDER BY Total_Restaurants DESC
LIMIT 20;

-- 3. What are the monthly order trends based on order volume over time? 

SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS Order_Month,
    COUNT(order_pk) AS Total_Orders
FROM orders
WHERE order_date IS NOT NULL
GROUP BY Order_Month
ORDER BY Order_Month;

-- 4. What are the top 5 most popular cuisines by order volume? 
with rest_volume as (
select r.cuisine as pp_cusinines ,count(o.sales_qty) as order_volume from restaurant r
join orders o on r.id = o.r_id 
group by r.cuisine ) 
select rk , pp_cusinines ,  order_volume from (
select *,row_number() over(order by order_volume desc) as rk 
from rest_volume) x 
where rk <= 5;

-- 5. What is the distribution of vegetarian vs non-vegetarian items ordered? 

SELECT 
    f.veg_or_non_veg AS Category, 
    COUNT(m.menu_pk) AS Total_Items,
    ROUND(COUNT(m.menu_pk) * 100.0 / (SELECT COUNT(*) FROM menu), 2) AS Percentage
FROM menu m
JOIN food f ON m.f_id = f.f_id
GROUP BY Category;

-- 6. What are the top 20 cities by the number of restaurants? 
SELECT rk, city, total_restaurant
FROM ( SELECT city, COUNT(name) AS total_restaurant,
			ROW_NUMBER() OVER (ORDER BY COUNT(name) DESC) AS rk
    FROM restaurant
    GROUP BY city
) t
WHERE rk <= 20;

-- 7. How do different user demographics correlate with average order 
-- value? 
SELECT 
    u.Occupation, 
    ROUND(AVG(o.sales_amount), 2) AS Avg_Order_Value
FROM orders o
JOIN users u ON o.user_id = u.user_id
GROUP BY u.Occupation
ORDER BY Avg_Order_Value DESC;

-- 8. Who are the top 15 highest-spending users? 
SELECT 
    u.user_id, 
    u.name, 
    SUM(o.sales_amount) AS Total_Spent
FROM orders o
JOIN users u ON o.user_id = u.user_id
GROUP BY u.user_id, u.name
ORDER BY Total_Spent DESC
LIMIT 15;


-- 9. What are the top 15 cuisines with the highest average menu prices? 
SELECT 
    cuisine, 
    ROUND(AVG(price), 2) AS Avg_Price
FROM menu
GROUP BY cuisine
ORDER BY Avg_Price DESC
LIMIT 15;



-- 10. Which restaurants offer the most diverse menu, based on the 
-- number of unique cuisines and dishes available? 
SELECT 
    r.name AS Restaurant_Name, 
    COUNT(DISTINCT m.f_id) AS Unique_Items_Count
FROM menu m
JOIN restaurant r ON m.r_id = r.id
GROUP BY r.name
ORDER BY Unique_Items_Count DESC
LIMIT 10;

-- 11. What are the most ordered food items across all restaurants? 
SELECT 
    f.item, 
    COUNT(m.menu_pk) AS Times_Listed_On_Menus
FROM menu m
JOIN food f ON m.f_id = f.f_id
GROUP BY f.item
ORDER BY Times_Listed_On_Menus DESC
LIMIT 15;

-- 12. How does spending behavior differ between genders? 
SELECT 
    u.Gender, 
    COUNT(o.order_pk) AS Total_Orders, 
    SUM(o.sales_amount) AS Total_Sales, 
    ROUND(AVG(o.sales_amount), 2) AS Avg_Spend_Per_Order
FROM orders o
JOIN users u ON o.user_id = u.user_id
GROUP BY u.Gender;
-- 13. On which days of the week do restaurants experience peak order 
-- volumes? 

SELECT 
    DAYNAME(order_date) AS Day_Name, 
    COUNT(order_pk) AS Order_Volume
FROM orders
WHERE order_date IS NOT NULL
GROUP BY Day_Name
ORDER BY Order_Volume DESC;

-- 14. How does order frequency vary across different income groups? 

SELECT 
    CASE 
        WHEN u.monthly_income_int = 0 THEN 'No Income'
        WHEN u.monthly_income_int < 25000 THEN 'Low Income'
        WHEN u.monthly_income_int BETWEEN 25000 AND 50000 THEN 'Medium Income'
        ELSE 'High Income'
    END AS Income_Bracket,
    COUNT(o.order_pk) AS Total_Orders,
    ROUND(AVG(o.sales_amount), 2) AS Avg_Order_Value
FROM orders o
JOIN users u ON o.user_id = u.user_id
GROUP BY Income_Bracket
ORDER BY Total_Orders DESC;