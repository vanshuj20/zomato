 Zomato Data Engineering & Analytics Project

## 📌 Project Overview

This project focuses on building a robust end-to-end data pipeline to clean, normalize, and analyze a high-volume food delivery dataset. Using *MySQL, I processed over 1 million records of messy raw data into a structured **Star Schema*, enabling deep dives into customer spending behavior and restaurant performance.

## 🏗 Database Schema (The Logic)

The database is designed around a central *Fact Table* (Orders) connected to multiple *Dimension Tables* (Users, Restaurants, Food, Menu).

### *Table Connections:*

* *Users ↔ Orders (1:N):* Tracks who is ordering based on demographics (Age, Marital Status, Education, Income).
* *Restaurants ↔ Orders (1:N):* Identifies where orders are coming from (City, Ratings, License No).
* *Menu ↔ Food/Restaurant:* A bridge table that connects specific dishes to restaurants with their respective prices.

---

## 🛠 Data Cleaning & Feature Engineering

The project involved extensive SQL scripting to move from raw, "dirty" data to analysis-ready information:

* *Primary Key Enforcement:* Assigned unique order_pk, user_id, and restaurant_pk to ensure data integrity.
* *String Sanitization:* Cleaned Gender, Occupation, and Education categories using CASE statements and TRIM() functions.
* *Numeric Conversion:* Transformed text-based "Monthly Income" into monthly_income_int for quantitative correlation.
* *Date Formatting:* Validated order_date using REGEXP to remove junk strings and cast them into standard DATE types.
* *Advanced Filtering:* Handled nulls and outliers in Age (0-100) and Family size (1-20).

---

## 📊 Business Insights Extracted

Using the cleaned schema, I solved 15+ complex business questions:

* *Top Performers:* Identified the top 10 restaurants and cities by total revenue.
* *User Segmentation:* Analyzed how *Family Size* and *Marital Status* correlate with average order quantity (sales_qty).
* *Trend Analysis:* Discovered peak ordering days and monthly volume trends.
* *Cuisine Strategy:* Ranked the top 5 cuisines by order volume and average menu price.
* *Gender Analysis:* Compared spending behavior and average order values between genders.

---

## 🛠 Tech Stack

* *SQL:* MySQL (Joins, CTEs, Window Functions, Aggregate Functions, DDL/DML).
* *Architecture:* Star Schema / Relational Database Design.
* *Tools:* MySQL Workbench, Data Modeling.

---

## 🚀 How to Use

1. Import the provided SQL scripts into your MySQL environment.
2. Run the *Cleaning Scripts* first to set up the keys and standardized values.
3. Execute the *Analytics Queries* to generate reports on user demographics and sales trends.
