-- Q1. SELECT clause with WHERE, AND, DISTINCT, Wild Card (LIKE)
-- a. Fetch the employee number, first name and last name of those employees who are working as Sales Rep reporting to employee with employeenumber.

SELECT DISTINCT employeeNumber, firstName, lastName
FROM employees
WHERE jobTitle LIKE '%Sales Rep%'
  AND reportsTo = 1102;
  
  -- b. Show the unique productline values containing the word cars at the end from the products table.
  
  SELECT DISTINCT productLine
FROM products
WHERE productLine LIKE '%Cars';

-- Q2. CASE STATEMENTS for Segmentation
-- a. Using a CASE statement, segment customers into three categories based on their country

SELECT customerNumber, customerName,
       CASE
           WHEN country IN ('USA', 'Canada') THEN 'North America'
           WHEN country IN ('UK', 'France', 'Germany') THEN 'Europe'
           ELSE 'Other'
       END AS CustomerSegment
FROM customers;

-- Q3. Group By with Aggregation functions and Having clause, Date and Time functions
-- a. Using the OrderDetails table, identify the top 10 products (by productCode) with the highest total order quantity across all orders.

SELECT productCode, SUM(quantityOrdered) AS totalQuantity
FROM orderdetails
GROUP BY productCode
ORDER BY totalQuantity DESC
LIMIT 10;

-- b. Company wants to analyse payment frequency by month. Extract the month name from the payment date to count the total number of payments for each month and include only those months with a payment count exceeding 20. Sort the results by total number of payments in descending order.

SELECT MONTHNAME(paymentDate) AS Month, COUNT(*) AS PaymentCount
FROM payments
GROUP BY Month
HAVING PaymentCount > 20
ORDER BY PaymentCount DESC;

-- Q4. CONSTRAINTS: Primary, key, foreign key, Unique, check, not null, default
-- Create a new database named and Customers_Orders and add the following tables as per the description.
-- a. Create a table named Customers to store customer information.

CREATE DATABASE Customers_Orders;

USE Customers_Orders;

CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone_number VARCHAR(20)
);

-- b. Create a table named Orders to store information about customer orders.

CREATE TABLE Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10,2) CHECK (total_amount > 0),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- Q5. JOINS
-- a. List the top 5 countries (by order count) that Classic Models ships to. (Use the Customers and Orders tables)

USE classicmodels;

SELECT c.country, COUNT(o.orderNumber) AS OrderCount
FROM customers c
JOIN orders o ON c.customerNumber = o.customerNumber
GROUP BY c.country
ORDER BY OrderCount DESC
LIMIT 5;

-- Q6. SELF JOIN
-- a. Create a table project with below fields.

CREATE TABLE project (
    EmployeeID INT AUTO_INCREMENT PRIMARY KEY,
    FullName VARCHAR(50) NOT NULL,
    Gender ENUM('Male', 'Female') NOT NULL,
    ManagerID INT
);

INSERT INTO project (FullName, Gender, ManagerID)
VALUES 
('Pranaya', 'Male', 3),
('Priyanka', 'Female', 1),
('Preety', 'Female', NULL),
('Anurag', 'Male', 1),
('Sambit', 'Male', 1),
('Rajesh', 'Male', 3),
('Hina', 'Female', 3);

SELECT 
    M.FullName AS 'Manager Name',
    E.FullName AS 'Emp Name'
FROM 
    project E
JOIN 
    project M
ON 
    E.ManagerID = M.EmployeeID;
    
-- Q7. DDL Commands: Create, Alter, Rename
-- a. Create table facility. 
   
CREATE TABLE facility (
    Facility_ID INT NOT NULL,
    Name VARCHAR(100),
    State VARCHAR(100),
    Country VARCHAR(100)
);

-- i) Alter the table by adding the primary key and auto increment to Facility_ID column.

ALTER TABLE facility
MODIFY Facility_ID INT NOT NULL AUTO_INCREMENT,
ADD PRIMARY KEY (Facility_ID);

-- ii) Add a new column city after name with data type as varchar which should not accept any null values.

ALTER TABLE facility
ADD City VARCHAR(100) NOT NULL AFTER Name;

-- Q8. Views in SQL
-- a. Create a view named product_category_sales that provides insights into sales performance by product category.

SELECT * FROM classicmodels.product_category_sales;

-- Q9. Stored Procedures in SQL with parameters
-- a. Create a stored procedure Get_country_payments which takes in year and country as inputs and gives year wise, country wise total amount as an output. Format the total amount to nearest thousand unit (K)

call classicmodels.Get_country_payments(2003, 'France');

-- Q10. Window functions - Rank, dense_rank, lead and lag
-- a. Using customers and orders tables, rank the customers based on their order frequency

SELECT 
    c.customerName,
    COUNT(o.orderNumber) AS Order_count,
    RANK() OVER (ORDER BY COUNT(o.orderNumber) DESC) AS order_frequency_rnk
FROM 
    Customers c
LEFT JOIN 
    Orders o ON c.customerNumber = o.customerNumber
GROUP BY 
    c.customerName
ORDER BY 
    order_frequency_rnk;
    
    -- b) Calculate year wise, month name wise count of orders and year over year (YoY) percentage change. Format the YoY values in no decimals and show in % sign.
    
    WITH monthly_orders AS (
    SELECT 
        YEAR(orderDate) AS Year,
        MONTHNAME(orderDate) AS Month,
        COUNT(orderNumber) AS TotalOrders
    FROM Orders
    GROUP BY YEAR(orderDate), MONTH(orderDate), MONTHNAME(orderDate)
),
ordered_data AS (
    SELECT 
        Year,
        Month,
        TotalOrders,
        LAG(TotalOrders) OVER (PARTITION BY MONTH(Month) ORDER BY Year) AS PrevYearOrders
    FROM monthly_orders
)
SELECT 
    Year,
    Month,
    TotalOrders,
    CASE 
        WHEN PrevYearOrders IS NULL THEN 'NULL'
        ELSE CONCAT(ROUND(((TotalOrders - PrevYearOrders) / PrevYearOrders) * 100, 0), '%')
    END AS `% YoY Change`
FROM ordered_data
ORDER BY Year, STR_TO_DATE(Month, '%M');

-- Q11. Subqueries and their applications
-- a. Find out how many product lines are there for which the buy price value is greater than the average of buy price value. Show the output as product line and its count.

SELECT productLine, COUNT(*) AS Total
FROM products
WHERE buyPrice > (SELECT AVG(buyPrice) FROM products)
GROUP BY productLine
HAVING COUNT(*) >= 1;

-- Q12. ERROR HANDLING in SQL

CREATE TABLE Emp_EH (
    EmpID INT PRIMARY KEY,
    EmpName NVARCHAR(100),
    EmailAddress NVARCHAR(255)
);

call classicmodels.InsertEmp_EH(1, 'Sahana', 'iamsahana@gmail.com');
call classicmodels.InsertEmp_EH(1, 'Sahana', 'iamsahana@gmail.com');

-- Q13. TRIGGERS

CREATE TABLE Emp_BIT (
    Name NVARCHAR(100),
    Occupation NVARCHAR(100),
    Working_date DATE,
    Working_hours INT
);
INSERT INTO Emp_BIT VALUES
('Robin', 'Scientist', '2020-10-04', 12),  
('Warner', 'Engineer', '2020-10-04', 10),  
('Peter', 'Actor', '2020-10-04', 13),  
('Marco', 'Doctor', '2020-10-04', 14),  
('Brayden', 'Teacher', '2020-10-04', 12),  
('Antonio', 'Business', '2020-10-04', 11);

-- Insert data with negative Working_hours to test the trigger
INSERT INTO Emp_BIT VALUES ('Lucy', 'Artist', '2020-10-04', -8);

-- Verify the result
SELECT * FROM Emp_BIT;







        


























