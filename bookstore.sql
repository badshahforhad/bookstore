USE Bookstore;


-- Drop tables in correct order
IF OBJECT_ID('OrderDetails', 'U') IS NOT NULL
    DROP TABLE OrderDetails;
IF OBJECT_ID('Orders', 'U') IS NOT NULL
    DROP TABLE Orders;
IF OBJECT_ID('Books', 'U') IS NOT NULL
    DROP TABLE Books;
IF OBJECT_ID('Customers', 'U') IS NOT NULL
    DROP TABLE Customers;
IF OBJECT_ID('Authors', 'U') IS NOT NULL
    DROP TABLE Authors;


-- Create 5 tables: Authors, Books, Customers, Orders, OrderDetails
-- Create Authors table
CREATE TABLE Authors (
    AuthorID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Bio VARCHAR(500)
);

-- Create Books table
CREATE TABLE Books (
    BookID INT IDENTITY(1,1) PRIMARY KEY,
    Title VARCHAR(200) NOT NULL,
    Genre VARCHAR(50),
    Price DECIMAL(10,2) NOT NULL,
    Stock INT NOT NULL,
    AuthorID INT,
    FOREIGN KEY (AuthorID) REFERENCES Authors(AuthorID)
);
EXEC sp_help 'Books';


-- Create Customers table
CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE,
    Address VARCHAR(200)
);

-- Create Orders table
CREATE TABLE Orders (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT,
    OrderDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- Create OrderDetails table (junction table)
CREATE TABLE OrderDetails (
    OrderDetailID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT,
    BookID INT,
    Quantity INT,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (BookID) REFERENCES Books(BookID)
);




-- Insert Sample Data
-- Insert Authors
INSERT INTO Authors (Name, Bio)
VALUES
('J.K. Rowling', 'Author of the Harry Potter series'),
('George R.R. Martin', 'Author of A Song of Ice and Fire'),
('Agatha Christie', 'Famous mystery writer');
SELECT * FROM Authors;


-- Insert Books
SET IDENTITY_INSERT Books ON;

INSERT INTO Books (BookID, Title, Genre, Price, Stock, AuthorID)
VALUES
(55, 'Harry Potter and the Philosopher''s Stone', 'Fantasy', 20.99, 55, 1),
(70, 'A Game of Thrones', 'Fantasy', 25.50, 30, 2),
(33, 'Murder on the Orient Express', 'Mystery', 15.00, 40, 3);

SET IDENTITY_INSERT Books OFF;

SELECT * FROM Books;

-----------------------


-- Verify it was added
SELECT * FROM Books WHERE BookID = 999;


-- Insert Customers
INSERT INTO Customers (Name, Email, Address)
VALUES
('Alice Johnson', 'alice@example.com', '123 Main St'),
('Bob Smith', 'bob@example.com', '456 Oak Ave'),
('Charlie Brown', 'charlie@example.com', '789 Pine Rd');
SELECT * FROM Customers;

-- Insert Orders
INSERT INTO Orders (CustomerID, OrderDate)
VALUES
(1, '2025-12-01'),
(2, '2025-12-02'),
(1, '2025-12-03');
SELECT * FROM Orders;

-- Insert Order Details
INSERT INTO OrderDetails (OrderID, BookID, Quantity)
VALUES
(1, 1, 2),  
(1, 3, 1),
(2, 2, 1),  
(3, 1, 1); 
SELECT * FROM OrderDetails;


-- Creating Indexes
-- Orders.CustomerID
CREATE INDEX IDX_Orders_CustomerID
ON Orders (CustomerID);

/*-- Books.AuthorID
CREATE INDEX IDX_Books_AuthorID
ON Books (AuthorID);

-- OrderDetails(OrderID, BookID)
CREATE INDEX IDX_OrderDetails_OrderID_BookID
ON OrderDetails (OrderID, BookID);*/



-- Data Manipulation
-- UPDATE Operations
-- Show the book BEFORE update
SELECT BookID, Title, Stock
FROM Books
WHERE BookID = 1;

-- UPDATE: reduce stock by 1 for BookID = 1
UPDATE Books
SET Stock = Stock - 1
WHERE BookID = 1;
SELECT * FROM Books;

-- AFTER: verify stock decreased
SELECT BookID, Title, Stock
FROM Books
WHERE BookID = 1;



-- UPDATE: restock a book (add 10 copies to BookID = 2)
-- BEFORE: check stock for BookID = 2
SELECT BookID, Title, Stock
FROM Books
WHERE BookID = 2;

-- UPDATE: add 10 to stock
UPDATE Books
SET Stock = Stock + 10
WHERE BookID = 2;
SELECT * FROM Books;

-- AFTER: verify new stock level
SELECT BookID, Title, Stock
FROM Books
WHERE BookID = 2;


-- UPDATE: change customer email (CustomerID = 1)
-- BEFORE: show current customer email
SELECT CustomerID, Name, Email
FROM Customers
WHERE CustomerID = 1;

-- UPDATE: change the email
UPDATE Customers
SET Email = 'alice.new@example.com'
WHERE CustomerID = 1;
SELECT * FROM Customers;

-- AFTER: confirm the change
SELECT CustomerID, Name, Email
FROM Customers
WHERE CustomerID = 1;



-- DELETE: remove a single OrderDetails row (e.g., customer canceled one line)
-- Insert new OrderDetails
INSERT INTO OrderDetails (OrderID, BookID, Quantity)
VALUES
(1, 2, 55), 
(2, 3, 55), 
(3, 1, 55);  

-- BEFORE: show the order details table
SELECT * FROM OrderDetails;


-- DELETE: remove the specific OrderDetails row
DELETE FROM OrderDetails
WHERE OrderDetailID = 3;

-- AFTER: show OrderDetails to confirm deletion
SELECT * FROM OrderDetails;


-- Indepentdent Table
CREATE TABLE TEMPFORTRUNCATE(
	ID INT,
	NAME NVARCHAR(50));

INSERT INTO TEMPFORTRUNCATE( ID, NAME)
	VALUES(1,'TEMP');

SELECT * FROM TEMPFORTRUNCATE

DROP TABLE TEMPFORTRUNCATE;


TRUNCATE TABLE TEMPFORTRUNCATE; --result


-- Data Retrieval and Queries
-- SELECT with JOIN + ORDER BY
-- List all orders with customer and book details, sorted by customer name A→Z
SELECT 
    O.OrderID,
    C.Name AS CustomerName,
    B.Title AS BookTitle,
    OD.Quantity
FROM OrderDetails OD
JOIN Orders O ON OD.OrderID = O.OrderID
JOIN Customers C ON O.CustomerID = C.CustomerID
JOIN Books B ON OD.BookID = B.BookID
ORDER BY C.Name ASC;




-- SELECT with Aggregation + GROUP BY
-- SUM
SELECT 
    B.Title,
    SUM(OD.Quantity) AS TotalSold
FROM OrderDetails OD
JOIN Books B ON OD.BookID = B.BookID
GROUP BY B.Title
ORDER BY TotalSold DESC;

-- COUNT
SELECT 
    B.Title,
    COUNT(OD.OrderDetailID) AS TotalOrders
FROM OrderDetails OD
JOIN Books B ON OD.BookID = B.BookID
GROUP BY B.Title
ORDER BY TotalOrders DESC;

-- AVERAGE
SELECT 
    B.Title,
    AVG(OD.Quantity) AS AverageOrder
FROM OrderDetails OD
JOIN Books B ON OD.BookID = B.BookID
GROUP BY B.Title
ORDER BY AverageOrder DESC;
SELECT * FROM OrderDetails;


-- SELECT with Pagination (OFFSET / FETCH)
-- Show books in pages of 2 (pagination example)
SELECT BookID, Title, Price
FROM Books
ORDER BY Price DESC
OFFSET 0 ROWS
FETCH NEXT 6 ROWS ONLY;




-- INNER JOIN (Two Tables , Books + Authors)
-- Show books with their authors
SELECT 
    B.Title,
    B.Genre,
    A.Name AS Author
FROM Books B
INNER JOIN Authors A ON B.AuthorID = A.AuthorID;

-- LEFT JOIN (Two Tables, Customers + Orders)
SELECT 
    C.Name AS Customer,
    O.OrderID,
    O.OrderDate
FROM Customers C
LEFT JOIN Orders O 
    ON C.CustomerID = O.CustomerID;


-- JOIN Three Tables Together
SELECT 
    O.OrderID,
    C.Name AS Customer,
    B.Title AS Book,
    OD.Quantity
FROM OrderDetails OD
JOIN Orders O 
    ON OD.OrderID = O.OrderID
JOIN Customers C
    ON O.CustomerID = C.CustomerID
JOIN Books B
    ON OD.BookID = B.BookID;


-- Create & VIEW combining 3 tables
CREATE VIEW vw_OrderSummary AS
SELECT 
    O.OrderID,
    C.Name AS Customer,
    B.Title AS Book,
    OD.Quantity,
    O.OrderDate
FROM OrderDetails OD
JOIN Orders O ON OD.OrderID = O.OrderID
JOIN Customers C ON O.CustomerID = C.CustomerID
JOIN Books B ON OD.BookID = B.BookID;
GO

SELECT * FROM vw_OrderSummary;




-- Procedures/Functions/Triggers
-- STORED PROCEDURE
CREATE PROCEDURE GetCustomerOrders
    @CustomerID INT
AS
BEGIN
    SELECT 
        O.OrderID,
        O.OrderDate,
        B.Title AS BookTitle,
        OD.Quantity,
        B.Price,
        (OD.Quantity * B.Price) AS LineTotal
    FROM Orders O
    INNER JOIN OrderDetails OD ON O.OrderID = OD.OrderID
    INNER JOIN Books B ON OD.BookID = B.BookID
    WHERE O.CustomerID = @CustomerID
        ORDER BY O.OrderDate ASC;
END;
EXEC GetCustomerOrders @CustomerID = 1;

drop procedure GetCustomerOrders;


-- SQL FUNCTION — Calculate total cost of an order line
CREATE FUNCTION CalculateLineTotal
(
    @BookID INT,
    @Quantity INT
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @Price DECIMAL(10,2);

    SELECT @Price = Price FROM Books WHERE BookID = @BookID;

    RETURN @Price * @Quantity;
END;


SELECT dbo.CalculateLineTotal(3, 3) AS TotalPrice;




-- SQL TRIGGER — Auto-reduce stock when an order detail is added
CREATE TRIGGER ReduceStockAfterOrder
ON OrderDetails
AFTER INSERT
AS
BEGIN
    UPDATE Books
    SET Stock = Stock - inserted.Quantity
    FROM Books
    INNER JOIN inserted ON Books.BookID = inserted.BookID;
END;

-- Test the trigger
INSERT INTO OrderDetails (OrderID, BookID, Quantity)
VALUES (1, 1, 1);

SELECT BookID, Title, Stock FROM Books WHERE BookID = 1;


-- MANUAL TRANSACTION
BEGIN TRANSACTION;
BEGIN TRY
    -- Insert a new order for CustomerID = 1
    INSERT INTO Orders (CustomerID, OrderDate)
    VALUES (1, GETDATE());

    DECLARE @NewOrderID INT = SCOPE_IDENTITY();

    -- Insert order detail with invalid BookID to force rollback
    INSERT INTO OrderDetails (OrderID, BookID, Quantity)
    VALUES (@NewOrderID, 55, 1);  

    -- Commit if everything is fine
    COMMIT TRANSACTION;
    PRINT 'Transaction completed successfully!';
END TRY
BEGIN CATCH
    -- Rollback if error occurs
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    -- Show a clean, simple message instead of long SQL error
    PRINT 'Error occurred: transaction rolled back.';
    
END CATCH;



SELECT * FROM Orders ORDER BY OrderID DESC;
SELECT * FROM OrderDetails ORDER BY OrderDetailID DESC;



BEGIN TRANSACTION;  
-- Insert a new order for CustomerID = 1
INSERT INTO Orders (CustomerID, OrderDate)
VALUES (1, GETDATE());

-- Get the new OrderID automatically
DECLARE @NewOrderID INT;
SET @NewOrderID = SCOPE_IDENTITY();

-- Insert one order detail (BookID = 1, Quantity = 2)
INSERT INTO Orders (CustomerID, OrderDate)
VALUES (1, GETDATE());  -- 1 exists in Customers


COMMIT;

-- Check the results
SELECT * FROM Orders ORDER BY OrderID DESC;
SELECT * FROM OrderDetails ORDER BY OrderDetailID DESC;
