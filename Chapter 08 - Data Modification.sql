---------------------------------------------------------------------
-- Microsoft SQL Server 2008 T-SQL Fundamentals
-- Chapter 8 - Data Modification
-- © 2008 Itzik Ben-Gan 
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Inserting Data
---------------------------------------------------------------------

---------------------------------------------------------------------
-- INSERT VALUES
---------------------------------------------------------------------

USE tempdb;

IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL DROP TABLE dbo.Orders;

CREATE TABLE dbo.Orders
(
  orderid   INT         NOT NULL
    CONSTRAINT PK_Orders PRIMARY KEY,
  orderdate DATE        NOT NULL
    CONSTRAINT DFT_orderdate DEFAULT(CURRENT_TIMESTAMP),
  empid     INT         NOT NULL,
  custid    VARCHAR(10) NOT NULL
)

INSERT INTO dbo.Orders(orderid, orderdate, empid, custid)
  VALUES(10001, '20090212', 3, 'A');

INSERT INTO dbo.Orders(orderid, empid, custid)
  VALUES(10002, 5, 'B');

INSERT INTO dbo.Orders
  (orderid, orderdate, empid, custid)
VALUES
  (10003, '20090213', 4, 'B'),
  (10004, '20090214', 1, 'A'),
  (10005, '20090213', 1, 'C'),
  (10006, '20090215', 3, 'C');

SELECT *
FROM ( VALUES
         (10003, '20090213', 4, 'B'),
         (10004, '20090214', 1, 'A'),
         (10005, '20090213', 1, 'C'),
         (10006, '20090215', 3, 'C') )
     AS O(orderid, orderdate, empid, custid);

---------------------------------------------------------------------
-- INSERT SELECT
---------------------------------------------------------------------

USE tempdb;

INSERT INTO dbo.Orders(orderid, orderdate, empid, custid)
  SELECT orderid, orderdate, empid, custid
  FROM TSQLFundamentals2008.Sales.Orders
  WHERE shipcountry = 'UK';

INSERT INTO dbo.Orders(orderid, orderdate, empid, custid)
  SELECT 10007, '20090215', 2, 'B' UNION ALL
  SELECT 10008, '20090215', 1, 'C' UNION ALL
  SELECT 10009, '20090216', 2, 'C' UNION ALL
  SELECT 10010, '20090216', 3, 'A';

---------------------------------------------------------------------
-- INSERT EXEC
---------------------------------------------------------------------

USE TSQLFundamentals2008;

IF OBJECT_ID('Sales.usp_getorders', 'P') IS NOT NULL
  DROP PROC Sales.usp_getorders;
GO

CREATE PROC Sales.usp_getorders
  @country AS NVARCHAR(40)
AS

SELECT orderid, orderdate, empid, custid
FROM Sales.Orders
WHERE shipcountry = @country;
GO

EXEC Sales.usp_getorders @country = 'France';

USE tempdb;

INSERT INTO dbo.Orders(orderid, orderdate, empid, custid)
  EXEC TSQLFundamentals2008.Sales.usp_getorders @country = 'France';

---------------------------------------------------------------------
-- SELECT INTO
---------------------------------------------------------------------

USE tempdb;

IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL DROP TABLE dbo.Orders;

SELECT orderid, orderdate, empid, custid
INTO dbo.Orders
FROM TSQLFundamentals2008.Sales.Orders;

-- SELECT INTO with Set Operations
USE tempdb;

IF OBJECT_ID('dbo.Locations', 'U') IS NOT NULL DROP TABLE dbo.Locations;

SELECT country, region, city
INTO dbo.Locations
FROM TSQLFundamentals2008.Sales.Customers

EXCEPT

SELECT country, region, city
FROM TSQLFundamentals2008.HR.Employees;

---------------------------------------------------------------------
-- BULK INSERT
---------------------------------------------------------------------

USE tempdb;

BULK INSERT dbo.Orders FROM 'c:\temp\orders.txt'
  WITH 
    (
       DATAFILETYPE    = 'char',
       FIELDTERMINATOR = ',',
       ROWTERMINATOR   = '\n'
    );
GO

---------------------------------------------------------------------
-- IDENTITY
---------------------------------------------------------------------

USE tempdb;

IF OBJECT_ID('dbo.T1', 'U') IS NOT NULL DROP TABLE dbo.T1;

CREATE TABLE dbo.T1
(
  keycol  INT         NOT NULL IDENTITY(1, 1)
    CONSTRAINT PK_T1 PRIMARY KEY,
  datacol VARCHAR(10) NOT NULL
    CONSTRAINT CHK_T1_datacol CHECK(datacol LIKE '[A-Z]%')
);
GO

INSERT INTO dbo.T1(datacol) VALUES('AAAAA');
INSERT INTO dbo.T1(datacol) VALUES('CCCCC');
INSERT INTO dbo.T1(datacol) VALUES('BBBBB');

SELECT * FROM dbo.T1;

SELECT $identity FROM dbo.T1;

-- Using SCOPE_IDENTITY
DECLARE @new_key AS INT;

INSERT INTO dbo.T1(datacol) VALUES('AAAAA');

SET @new_key = SCOPE_IDENTITY();

SELECT @new_key AS new_key

-- Run from another connection
SELECT
  SCOPE_IDENTITY() AS [SCOPE_IDENTITY],
  @@identity AS [@@identity],
  IDENT_CURRENT('dbo.T1') AS [IDENT_CURRENT];
GO

-- Run insert statements
INSERT INTO dbo.T1(datacol) VALUES('12345');
GO
INSERT INTO dbo.T1(datacol) VALUES('EEEEE');
GO

SELECT * FROM dbo.T1;

-- Using IDENTITY_INSERT 
SET IDENTITY_INSERT dbo.T1 ON;
INSERT INTO dbo.T1(keycol, datacol) VALUES(5, 'FFFFF');
SET IDENTITY_INSERT dbo.T1 OFF;

INSERT INTO dbo.T1(datacol) VALUES('GGGGG');

SELECT * FROM dbo.T1;

---------------------------------------------------------------------
-- Deleting Data
---------------------------------------------------------------------

USE tempdb;

IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL DROP TABLE dbo.Orders;
IF OBJECT_ID('dbo.Customers', 'U') IS NOT NULL DROP TABLE dbo.Customers;

SELECT * INTO dbo.Customers FROM TSQLFundamentals2008.Sales.Customers;
SELECT * INTO dbo.Orders FROM TSQLFundamentals2008.Sales.Orders;

ALTER TABLE dbo.Customers ADD
  CONSTRAINT PK_Customers PRIMARY KEY(custid);
ALTER TABLE dbo.Orders ADD
  CONSTRAINT PK_Orders PRIMARY KEY(orderid),
  CONSTRAINT FK_Orders_Customers FOREIGN KEY(custid)
    REFERENCES dbo.Customers(custid);
GO

---------------------------------------------------------------------
-- DELETE Statement
---------------------------------------------------------------------

USE tempdb;

DELETE FROM dbo.Orders
WHERE orderdate < '20070101';

---------------------------------------------------------------------
-- TRUNCATE
---------------------------------------------------------------------

TRUNCATE TABLE dbo.T1;

---------------------------------------------------------------------
-- DELETE Based on a Join
---------------------------------------------------------------------

USE tempdb;

DELETE FROM O
FROM dbo.Orders AS O
  JOIN dbo.Customers AS C
    ON O.custid = C.custid
WHERE C.country = N'USA';

-- Using a subquery
DELETE FROM dbo.Orders
WHERE EXISTS
  (SELECT *
   FROM dbo.Customers AS C
   WHERE Orders.custid = C.custid
     AND C.country = N'USA');

---------------------------------------------------------------------
-- Updating Data
---------------------------------------------------------------------

USE tempdb;

IF OBJECT_ID('dbo.OrderDetails', 'U') IS NOT NULL DROP TABLE dbo.OrderDetails;
IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL DROP TABLE dbo.Orders;

SELECT * INTO dbo.Orders FROM TSQLFundamentals2008.Sales.Orders;
SELECT * INTO dbo.OrderDetails FROM TSQLFundamentals2008.Sales.OrderDetails;

ALTER TABLE dbo.Orders ADD
  CONSTRAINT PK_Orders PRIMARY KEY(orderid);
ALTER TABLE dbo.OrderDetails ADD
  CONSTRAINT PK_OrderDetails PRIMARY KEY(orderid, productid),
  CONSTRAINT FK_OrderDetails_Orders FOREIGN KEY(orderid)
    REFERENCES dbo.Orders(orderid);

---------------------------------------------------------------------
-- UPDATE Statement
---------------------------------------------------------------------

USE tempdb;

UPDATE dbo.OrderDetails
  SET discount = discount + 0.05
WHERE productid = 51;

-- In SQL Server 2008
UPDATE dbo.OrderDetails
  SET discount += 0.05
WHERE productid = 51;
GO

UPDATE dbo.T1
  SET col1 = col1 + 10, col2 = col1 + 10;

UPDATE dbo.T1
  SET col1 = col2, col2 = col1;
GO

---------------------------------------------------------------------
-- UPDATE Based on a Join
---------------------------------------------------------------------

-- Listing 8-1 Update Statement Based on a Join
UPDATE OD
  SET discount = discount + 0.05
FROM dbo.OrderDetails AS OD
  JOIN dbo.Orders AS O
    ON OD.orderid = O.orderid
WHERE custid = 1;

UPDATE dbo.OrderDetails
  SET discount = discount + 0.05
WHERE EXISTS
  (SELECT * FROM dbo.Orders AS O
   WHERE O.orderid = OrderDetails.orderid
     AND custid = 1);
GO

UPDATE T1
  SET col1 = T2.col1,
      col2 = T2.col2,
      col3 = T2.col3
FROM dbo.T1 JOIN dbo.T2
  ON T2.keycol = T1.keycol
WHERE T2.col4 = 'ABC';

UPDATE dbo.T1
  SET col1 = (SELECT col1
              FROM dbo.T2
              WHERE T2.keycol = T1.keycol),
              
      col2 = (SELECT col2
              FROM dbo.T2
              WHERE T2.keycol = T1.keycol),
      
      col3 = (SELECT col3
              FROM dbo.T2
              WHERE T2.keycol = T1.keycol)
WHERE EXISTS
  (SELECT *
   FROM dbo.T2
   WHERE T2.keycol = T1.keycol
     AND T2.col4 = 'ABC');
GO

/*
UPDATE dbo.T1

  SET (col1, col2, col3) =

      (SELECT col1, col2, col3
       FROM dbo.T2
       WHERE T2.keycol = T1.keycol)
       
WHERE EXISTS
  (SELECT *
   FROM dbo.T2
   WHERE T2.keycol = T1.keycol
     AND T2.col4 = 'ABC');
*/     
GO
        
---------------------------------------------------------------------
-- Assignment UPDATE
---------------------------------------------------------------------

USE tempdb;
-- Custom Sequence
IF OBJECT_ID('dbo.Sequence', 'U') IS NOT NULL DROP TABLE dbo.Sequence;
CREATE TABLE dbo.Sequence(val INT NOT NULL);
INSERT INTO dbo.Sequence VALUES(0);

DECLARE @nextval AS INT;
UPDATE Sequence SET @nextval = val = val + 1;
SELECT @nextval;

---------------------------------------------------------------------
-- Merging Data
---------------------------------------------------------------------

-- Listing 8-2 Code that Creates and Populates Customers and CustomersStage
USE tempdb;

IF OBJECT_ID('dbo.Customers', 'U') IS NOT NULL DROP TABLE dbo.Customers;
GO

CREATE TABLE dbo.Customers
(
  custid      INT         NOT NULL,
  companyname VARCHAR(25) NOT NULL,
  phone       VARCHAR(20) NOT NULL,
  address     VARCHAR(50) NOT NULL,
  CONSTRAINT PK_Customers PRIMARY KEY(custid)
);

INSERT INTO dbo.Customers(custid, companyname, phone, address)
VALUES
  (1, 'cust 1', '(111) 111-1111', 'address 1'),
  (2, 'cust 2', '(222) 222-2222', 'address 2'),
  (3, 'cust 3', '(333) 333-3333', 'address 3'),
  (4, 'cust 4', '(444) 444-4444', 'address 4'),
  (5, 'cust 5', '(555) 555-5555', 'address 5');

IF OBJECT_ID('dbo.CustomersStage', 'U') IS NOT NULL DROP TABLE dbo.CustomersStage;
GO

CREATE TABLE dbo.CustomersStage
(
  custid      INT         NOT NULL,
  companyname VARCHAR(25) NOT NULL,
  phone       VARCHAR(20) NOT NULL,
  address     VARCHAR(50) NOT NULL,
  CONSTRAINT PK_CustomersStage PRIMARY KEY(custid)
);

INSERT INTO dbo.CustomersStage(custid, companyname, phone, address)
VALUES
  (2, 'AAAAA', '(222) 222-2222', 'address 2'),
  (3, 'cust 3', '(333) 333-3333', 'address 3'),
  (5, 'BBBBB', 'CCCCC', 'DDDDD'),
  (6, 'cust 6 (new)', '(666) 666-6666', 'address 6'),
  (7, 'cust 7 (new)', '(777) 777-7777', 'address 7');

-- Query tables
SELECT * FROM dbo.Customers;

SELECT * FROM dbo.CustomersStage;

-- MERGE Example 1: Update existing, add missing
MERGE INTO dbo.Customers AS TGT
USING dbo.CustomersStage AS SRC
  ON TGT.custid = SRC.custid
WHEN MATCHED THEN
  UPDATE SET
    TGT.companyname = SRC.companyname,
    TGT.phone = SRC.phone,
    TGT.address = SRC.address
WHEN NOT MATCHED THEN 
  INSERT (custid, companyname, phone, address)
  VALUES (SRC.custid, SRC.companyname, SRC.phone, SRC.address);

-- MERGE Example 2: Update existing, add missing, delete missing in source
MERGE dbo.Customers AS TGT
USING dbo.CustomersStage AS SRC
  ON TGT.custid = SRC.custid
WHEN MATCHED THEN
  UPDATE SET
    TGT.companyname = SRC.companyname,
    TGT.phone = SRC.phone,
    TGT.address = SRC.address
WHEN NOT MATCHED THEN 
  INSERT (custid, companyname, phone, address)
  VALUES (SRC.custid, SRC.companyname, SRC.phone, SRC.address)
WHEN NOT MATCHED BY SOURCE THEN
  DELETE;

-- MERGE Example 3: Update existing that changed, add missing
MERGE dbo.Customers AS TGT
USING dbo.CustomersStage AS SRC
  ON TGT.custid = SRC.custid
WHEN MATCHED AND 
       (   TGT.companyname <> SRC.companyname
        OR TGT.phone       <> SRC.phone
        OR TGT.address     <> SRC.address) THEN
  UPDATE SET
    TGT.companyname = SRC.companyname,
    TGT.phone = SRC.phone,
    TGT.address = SRC.address
WHEN NOT MATCHED THEN 
  INSERT (custid, companyname, phone, address)
  VALUES (SRC.custid, SRC.companyname, SRC.phone, SRC.address);

---------------------------------------------------------------------
-- Modifying Data through Table Expressions
---------------------------------------------------------------------

USE tempdb;

UPDATE OD
  SET discount = discount + 0.05
FROM dbo.OrderDetails AS OD
  JOIN dbo.Orders AS O
    ON OD.orderid = O.orderid
WHERE custid = 1;

WITH C AS
(
  SELECT custid, OD.orderid,
    productid, discount, discount + 0.05 AS newdiscount
  FROM dbo.OrderDetails AS OD
    JOIN dbo.Orders AS O
      ON OD.orderid = O.orderid
  WHERE custid = 1
)
UPDATE C
  SET discount = newdiscount;

UPDATE D
  SET discount = newdiscount
FROM ( SELECT custid, OD.orderid,
         productid, discount, discount + 0.05 AS newdiscount
       FROM dbo.OrderDetails AS OD
         JOIN dbo.Orders AS O
           ON OD.orderid = O.orderid
       WHERE custid = 1 ) AS D;

-- Update with row numbers
USE tempdb;

IF OBJECT_ID('dbo.T1', 'U') IS NOT NULL DROP TABLE dbo.T1;

CREATE TABLE dbo.T1(col1 INT, col2 INT);
GO

INSERT INTO dbo.T1(col1) VALUES(10);
INSERT INTO dbo.T1(col1) VALUES(20);
INSERT INTO dbo.T1(col1) VALUES(30);

SELECT * FROM dbo.T1;
GO

UPDATE dbo.T1
  SET col2 = ROW_NUMBER() OVER(ORDER BY col1);

/*
Msg 4108, Level 15, State 1, Line 2
Windowed functions can only appear in the SELECT or ORDER BY clauses.
*/
GO
  
WITH C AS
(
  SELECT col1, col2, ROW_NUMBER() OVER(ORDER BY col1) AS rownum
  FROM dbo.T1
)
UPDATE C
  SET col2 = rownum;

SELECT * FROM dbo.T1;

---------------------------------------------------------------------
-- Modifications with the TOP Option
---------------------------------------------------------------------

USE tempdb;

IF OBJECT_ID('dbo.OrderDetails', 'U') IS NOT NULL DROP TABLE dbo.OrderDetails;
IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL DROP TABLE dbo.Orders;

SELECT * INTO dbo.Orders FROM TSQLFundamentals2008.Sales.Orders;

DELETE TOP(50) FROM dbo.Orders;

UPDATE TOP(50) dbo.Orders
  SET freight = freight + 10.00;

WITH C AS
(
  SELECT TOP(50) *
  FROM dbo.Orders
  ORDER BY orderid
)
DELETE FROM C;

WITH C AS
(
  SELECT TOP(50) *
  FROM dbo.Orders
  ORDER BY orderid DESC
)
UPDATE C
  SET freight = freight + 10.00;

---------------------------------------------------------------------
-- The OUTPUT Clause
---------------------------------------------------------------------

---------------------------------------------------------------------
-- INSERT with OUTPUT
---------------------------------------------------------------------

USE tempdb;

IF OBJECT_ID('dbo.T1', 'U') IS NOT NULL DROP TABLE dbo.T1;
GO

CREATE TABLE dbo.T1
(
  keycol  INT          NOT NULL IDENTITY(1, 1) CONSTRAINT PK_T1 PRIMARY KEY,
  datacol NVARCHAR(40) NOT NULL
);

INSERT INTO dbo.T1(datacol)
  OUTPUT inserted.keycol, inserted.datacol
    SELECT lastname
    FROM TSQLFundamentals2008.HR.Employees
    WHERE country = N'USA';

DECLARE @NewRows TABLE(keycol INT, datacol NVARCHAR(40));

INSERT INTO dbo.T1(datacol)
  OUTPUT inserted.keycol, inserted.datacol
  INTO @NewRows
    SELECT lastname
    FROM TSQLFundamentals2008.HR.Employees
    WHERE country = N'UK';

SELECT * FROM @NewRows;

---------------------------------------------------------------------
-- DELETE with OUTPUT
---------------------------------------------------------------------

USE tempdb;
IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL DROP TABLE dbo.Orders;
SELECT * INTO dbo.Orders FROM TSQLFundamentals2008.Sales.Orders;

DELETE FROM dbo.Orders
  OUTPUT
    deleted.orderid,
    deleted.orderdate,
    deleted.empid,
    deleted.custid
WHERE orderdate < '20080101';

---------------------------------------------------------------------
-- UPDATE with OUTPUT
---------------------------------------------------------------------

USE tempdb;
IF OBJECT_ID('dbo.OrderDetails', 'U') IS NOT NULL DROP TABLE dbo.OrderDetails;
SELECT * INTO dbo.OrderDetails FROM TSQLFundamentals2008.Sales.OrderDetails;

UPDATE dbo.OrderDetails
  SET discount = discount + 0.05
OUTPUT
  inserted.productid,
  deleted.discount AS olddiscount,
  inserted.discount AS newdiscount
WHERE productid = 51;

---------------------------------------------------------------------
-- MERGE with OUTPUT
---------------------------------------------------------------------

-- First, run Listing 8-2 to recreate Customers and CustomersStage

USE tempdb;

MERGE INTO dbo.Customers AS TGT
USING dbo.CustomersStage AS SRC
  ON TGT.custid = SRC.custid
WHEN MATCHED THEN
  UPDATE SET
    TGT.companyname = SRC.companyname,
    TGT.phone = SRC.phone,
    TGT.address = SRC.address
WHEN NOT MATCHED THEN 
  INSERT (custid, companyname, phone, address)
  VALUES (SRC.custid, SRC.companyname, SRC.phone, SRC.address)
OUTPUT $action, inserted.custid,
  deleted.companyname AS oldcompanyname,
  inserted.companyname AS newcompanyname,
  deleted.phone AS oldphone,
  inserted.phone AS newphone,
  deleted.address AS oldaddress,
  inserted.address AS newaddress;

---------------------------------------------------------------------
-- Composable DML
---------------------------------------------------------------------

USE tempdb;
IF OBJECT_ID('dbo.ProductsAudit', 'U') IS NOT NULL DROP TABLE dbo.ProductsAudit;
IF OBJECT_ID('dbo.Products', 'U') IS NOT NULL DROP TABLE dbo.Products;

SELECT * INTO dbo.Products FROM TSQLFundamentals2008.Production.Products;

CREATE TABLE dbo.ProductsAudit
(
  LSN INT NOT NULL IDENTITY PRIMARY KEY,
  TS  DATETIME NOT NULL DEFAULT(CURRENT_TIMESTAMP),
  productid INT NOT NULL,
  colname SYSNAME NOT NULL,
  oldval SQL_VARIANT NOT NULL,
  newval SQL_VARIANT NOT NULL
);

INSERT INTO dbo.ProductsAudit(productid, colname, oldval, newval)
  SELECT productid, N'unitprice', oldval, newval
  FROM (UPDATE dbo.Products
          SET unitprice *= 1.15
        OUTPUT 
          inserted.productid,
          deleted.unitprice AS oldval,
          inserted.unitprice AS newval
        WHERE SupplierID = 1) AS D
  WHERE oldval < 20.0 AND newval >= 20.0;

SELECT * FROM dbo.ProductsAudit;
