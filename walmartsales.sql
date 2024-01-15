CREATE DATABASE IF NOT EXISTS walmartDatabase;

USE walmartDatabase;

CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    product_line VARCHAR(50) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    VAT FLOAT(6) NOT NULL,
    total DECIMAL(12,4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment_method VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11),
    gross_income DECIMAL(12,4) NOT NULL,
    rating  FLOAT(2) NOT NULL
);

-- -----------------------------------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------FEATURE ENGINEERING-------------------------------------------------------------------
-- time_of_day

SELECT 
	time,
    (CASE
		WHEN time BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN time BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
	END
    ) AS time_of_date
FROM sales;

ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);

UPDATE sales
SET time_of_day = (
	CASE
		WHEN time BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN time BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
	END
);

-- day_name
SELECT date, dayname(date)
FROM sales;

ALTER TABLE sales ADD day_name VARCHAR(10);

UPDATE sales
SET day_name = dayname(date);

-- month_name
SELECT date, monthname(date)
FROM sales;

ALTER TABLE sales ADD month_name VARCHAR(10);

UPDATE sales
SET month_name = monthname(date);
-- -----------------------------------------------------------------------------------------------------------------------------------------------
-- ----------------------------Generic questions------------------
-- What are the unique cities present in the data? count how many times it has occured?.-------------------
SELECT DISTINCT(city),count(city) AS count
FROM sales
GROUP BY city;

-- In which city is each branch?
SELECT DISTINCT(branch),city
FROM sales;

-- -------------------------------------------------------------------------------------
-- ----------------------------Product based questions--------------------------
-- How many unique product lines does the data have?------------------------------
SELECT COUNT(DISTINCT(product_line))
FROM sales;

-- What are the unique values of product lines? and count each,
SELECT DISTINCT(product_line), count(product_line)
FROM sales
GROUP BY product_line;

-- What is the most common payment method?
SELECT payment_method, count(payment_method) as payement_count
FROM sales
GROUP BY payment_method
ORDER BY payement_count DESC
LIMIT 1;

-- What is the most selling product line?
SELECT product_line, sum(quantity) as total_qty_sold
FROM sales
GROUP BY product_line
ORDER BY total_qty_sold DESC
LIMIT 1;

-- What is the total revenue by month?
SELECT month_name, sum(total) as total_revenue
FROM sales
GROUP BY month_name;

-- What month had the largest COGS?
SELECT month_name, sum(cogs) as total_cogs
FROM sales
GROUP BY month_name
ORDER BY total_cogs DESC
LIMIT 1;

-- What product line had the largest revenue?
SELECT product_line, sum(total) as total_revenue
FROM sales
GROUP BY product_line
ORDER BY total_revenue DESC
LIMIT 1;

-- What is the city with the largest revenue?
SELECT city, sum(total) as total_revenue
FROM sales
GROUP BY city
ORDER BY total_revenue DESC
LIMIT 1;

-- What product line had the largest VAT?
SELECT product_line, sum(vat) as total_vat
FROM sales
GROUP BY product_line
ORDER BY total_vat
LIMIT 1;

-- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
SELECT product_line, total,
		CASE 
			WHEN total> (select avg(total) from sales) then "Good"
		ELSE "Bad"
        END AS good_bad_rating
FROM sales;
	
-- Which branch sold more products than average product sold?
SELECT branch, sum(quantity) as total_qty_sold
FROM sales
GROUP BY branch
HAVING total_qty_sold > (SELECT avg(total_qty_sold) FROM (
			SELECT sum(quantity) as total_qty_sold
			FROM sales
			GROUP BY branch) AS subquery);

-- What is the most common product line by gender?
-- What is the average rating of each product line?
-- -------------------------------------------------------------------------------------------
-- ---------------------------------------Sales based questions------------------------------------------------
-- Number of sales made in each time of the day per weekday
SELECT day_name as weekday, time_of_day, sum(quantity)
FROM sales
GROUP BY weekday, time_of_day
ORDER BY field(weekday, 'Monday', 'Tuesday', 'Wednesday','Thursday', 'Friday', 'Saturday', 'Sunday'), 
		 field(time_of_day, 'Morning','Afternoon','Evening');
         
-- Which of the customer types brings the most revenue?
SELECT customer_type, sum(total) as total_revenue
FROM sales
GROUP BY customer_type
ORDER BY total_revenue DESC
LIMIT 1;
-- Which city has the largest tax percent/ VAT (Value Added Tax)?
SELECT city, sum(vat) as total_vat
FROM sales
GROUP BY city
ORDER BY total_vat DESC
LIMIT 1;
-- Which customer type pays the most in VAT?
SELECT customer_type, sum(vat) as total_vat
FROM sales
GROUP BY customer_type
ORDER BY total_vat DESC
LIMIT 1;
-- -------------------------------------------------------------------------------------------------------------------
-- ------------------------------------Customer based questions------------------------------------------------
-- How many unique customer types does the data have?
SELECT count(DISTINCT customer_type) as no_of_customer_types
FROM sales;

-- How many unique payment methods does the data have?
SELECT count(DISTINCT payment_method) as payment_types
FROM sales;

-- What is the most common customer type?
SELECT customer_type, count(customer_type) as total_customer
FROM sales
GROUP BY customer_type
ORDER BY total_customer DESC
LIMIT 1;

-- Which customer type buys the most?
SELECT customer_type, count(quantity) as total_buy
FROM sales
GROUP BY customer_type
ORDER BY total_buy DESC
LIMIT 1;

-- What is the gender of most of the customers?
SELECT gender, count(gender) as total_count
FROM sales
GROUP BY gender
ORDER BY gender DESC
LIMIT 1;

-- What is the gender distribution per branch?
SELECT branch, gender, count(gender)
FROM sales
GROUP BY branch, gender
ORDER BY branch;

-- Which time of the day do customers give most ratings?
-- Which time of the day do customers give most ratings per branch?
-- Which day fo the week has the best avg ratings?
-- Which day of the week has the best average ratings per branch?
