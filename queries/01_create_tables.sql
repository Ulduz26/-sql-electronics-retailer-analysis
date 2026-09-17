/* ============================================================
   Global Electronics Retailer - Database Schema
   Creates all 5 tables with appropriate data types, primary keys,
   and foreign key relationships.
   Order matters: Sales references the other 4 tables, so it must
   be created last.
   ============================================================ */

CREATE TABLE Stores (
    StoreKey INT PRIMARY KEY,
    Country NVARCHAR(100),
    State NVARCHAR(100),
    SquareMeters INT,
    OpenDate DATE
);

CREATE TABLE Products (
    ProductKey INT PRIMARY KEY,
    Product_Name NVARCHAR(100),
    Brand NVARCHAR(100),
    Color NVARCHAR(100),
    Unit_Cost_USD NVARCHAR(100),   -- staged as text at creation; cleaned in 02_data_cleaning.sql
    Unit_Price_USD NVARCHAR(100),  -- staged as text at creation; cleaned in 02_data_cleaning.sql
    SubcategoryKey NVARCHAR(100),  -- code with leading zeros, not a number
    Subcategory NVARCHAR(100),
    CategoryKey NVARCHAR(100),     -- code with leading zeros, not a number
    Category NVARCHAR(100)
);

CREATE TABLE Customers (
    CustomerKey INT PRIMARY KEY,
    Gender NVARCHAR(100),
    Name NVARCHAR(100),
    City NVARCHAR(100),
    State_Code NVARCHAR(100),
    State NVARCHAR(100),
    Zip_Code NVARCHAR(100),        -- not always numeric (e.g. Canadian postal codes)
    Country NVARCHAR(100),
    Continent NVARCHAR(100),
    Birthday DATE
);

CREATE TABLE Exchange_Rates (
    Date DATE,
    Currency CHAR(3),
    Exchange DECIMAL(5,4),
    PRIMARY KEY (Date, Currency)   -- composite key: neither column alone is unique
);

CREATE TABLE Sales (
    Order_Number INT,
    Line_Item INT,
    Order_Date DATE,
    Delivery_Date DATE,            -- nullable: ~49,719 orders have no delivery date yet
    CustomerKey INT,
    StoreKey INT,
    ProductKey INT,
    Quantity INT,
    Currency_Code CHAR(3),
    PRIMARY KEY (Order_Number, Line_Item),  -- composite key: one order can have multiple line items
    FOREIGN KEY (CustomerKey) REFERENCES Customers(CustomerKey),
    FOREIGN KEY (StoreKey) REFERENCES Stores(StoreKey),
    FOREIGN KEY (ProductKey) REFERENCES Products(ProductKey)
);
