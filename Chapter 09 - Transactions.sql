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
