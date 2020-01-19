---------------------------------------------------------------------
-- Microsoft SQL Server 2008 T-SQL Fundamentals
-- Chapter 9 - Transactions
-- © 2008 Itzik Ben-Gan 
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Transactions
---------------------------------------------------------------------

-- Transaction Example
USE TSQLFundamentals2008;

-- Start a new transaction
BEGIN TRAN;

  -- Declare a variable
  DECLARE @neworderid AS INT;

  -- Insert a new order into the Sales.Orders table
  INSERT INTO Sales.Orders
      (custid, empid, orderdate, requireddate, shippeddate, 
       shipperid, freight, shipname, shipaddress, shipcity,
       shippostalcode, shipcountry)
    VALUES
      (85, 5, '20090212', '20090301', '20090216',
       3, 32.38, N'Ship to 85-B', N'6789 rue de l''Abbaye', N'Reims',
       N'10345', N'France');

  -- Save the new order ID in a variable
  SET @neworderid = SCOPE_IDENTITY();

  -- Return the new order ID
  SELECT @neworderid AS neworderid;

  -- Insert order lines for new order into Sales.OrderDetails
  INSERT INTO Sales.OrderDetails
      (orderid, productid, unitprice, qty, discount)
    VALUES(@neworderid, 11, 14.00, 12, 0.000);
  INSERT INTO Sales.OrderDetails
      (orderid, productid, unitprice, qty, discount)
    VALUES(@neworderid, 42, 9.80, 10, 0.000);
  INSERT INTO Sales.OrderDetails
      (orderid, productid, unitprice, qty, discount)
    VALUES(@neworderid, 72, 34.80, 5, 0.000);

-- Commit the transaction
COMMIT TRAN;

-- Cleanup
DELETE FROM Sales.OrderDetails
WHERE orderid > 11077;

DELETE FROM Sales.Orders
WHERE orderid > 11077;

DBCC CHECKIDENT ('Sales.Orders', RESEED, 11077);

--////////////

-- Cleanup
UPDATE Production.Products
  SET unitprice = 19.00
WHERE productid = 2;

---------------------------------------------------------------------
-- Conflict Detection
---------------------------------------------------------------------

-- Connection 1, Step 1
SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

BEGIN TRAN;

  SELECT productid, unitprice
  FROM Production.Products
  WHERE productid = 2;

-- Connection 1, Step 2
  UPDATE Production.Products
    SET unitprice = 20.00
  WHERE productid = 2;
  
COMMIT TRAN;

-- Cleanup
UPDATE Production.Products
  SET unitprice = 19.00
WHERE productid = 2;

-- Connection 1, Step 1
BEGIN TRAN;

  SELECT productid, unitprice
  FROM Production.Products
  WHERE productid = 2;

-- Connection 2, Step 1
UPDATE Production.Products
  SET unitprice = 25.00
WHERE productid = 2;

-- Connection 1, Step 2
  UPDATE Production.Products
    SET unitprice = 20.00
  WHERE productid = 2;

-- Cleanup
UPDATE Production.Products
  SET unitprice = 19.00
WHERE productid = 2;

-- Close all connections

---------------------------------------------------------------------
-- The READ COMMITTED SNAPSHOT Isolation Level
---------------------------------------------------------------------

-- Turn on READ_COMMITTED_SNAPSHOT
ALTER DATABASE TSQLFundamentals2008 SET READ_COMMITTED_SNAPSHOT ON;

-- Connection 1
USE TSQLFundamentals2008;

BEGIN TRAN;

  UPDATE Production.Products
    SET unitprice = unitprice + 1.00
  WHERE productid = 2;

  SELECT productid, unitprice
  FROM Production.Products
  WHERE productid = 2;

-- Connection 2
BEGIN TRAN;

  SELECT productid, unitprice
  FROM Production.Products
  WHERE productid = 2;

-- Connection 1

COMMIT TRAN;

-- Connection 2

  SELECT productid, unitprice
  FROM Production.Products
  WHERE productid = 2;

COMMIT TRAN;

-- Cleanup
UPDATE Production.Products
  SET unitprice = 19.00
WHERE productid = 2;

-- Close all connections

-- Make sure you're back in default mode
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- Change database options to default
ALTER DATABASE TSQLFundamentals2008 SET ALLOW_SNAPSHOT_ISOLATION OFF;
ALTER DATABASE TSQLFundamentals2008 SET READ_COMMITTED_SNAPSHOT OFF;

---------------------------------------------------------------------
-- Deadlocks
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Simple Deadlock Example
---------------------------------------------------------------------

-- Connection 1
USE TSQLFundamentals2008;

BEGIN TRAN;

  UPDATE Production.Products
    SET unitprice = unitprice + 1.00
  WHERE productid = 2;

-- Connection 2
BEGIN TRAN;

  UPDATE Sales.OrderDetails
    SET unitprice = unitprice + 1.00
  WHERE productid = 2;

-- Connection 1

  SELECT orderid, productid, unitprice
  FROM Sales.OrderDetails
  WHERE productid = 2;

COMMIT TRAN;

-- Connection 2

  SELECT productid, unitprice
  FROM Production.Products
  WHERE productid = 2;

COMMIT TRAN;

-- Cleanup
UPDATE Production.Products
  SET unitprice = 19.00
WHERE productid = 2;

UPDATE Sales.OrderDetails
  SET unitprice = 19.00
WHERE productid = 2
  AND orderid >= 10500;

UPDATE Sales.OrderDetails
  SET unitprice = 15.20
WHERE productid = 2
  AND orderid < 10500;
