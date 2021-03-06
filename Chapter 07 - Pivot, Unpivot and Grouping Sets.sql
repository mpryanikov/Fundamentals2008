---------------------------------------------------------------------
-- Microsoft SQL Server 2008 T-SQL Fundamentals
-- Chapter 7 - Pivot, Unpivot and Grouping Sets
-- © 2008 Itzik Ben-Gan 
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Pivoting Data
---------------------------------------------------------------------

-- Listing 1: Code to Create and Populate the Orders Table
USE tempdb;

IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL DROP TABLE dbo.Orders;
GO

CREATE TABLE dbo.Orders
(
  orderid   INT        NOT NULL,
  orderdate DATE       NOT NULL, -- prior to SQL Server 2008 use DATETIME
  empid     INT        NOT NULL,
  custid    VARCHAR(5) NOT NULL,
  qty       INT        NOT NULL,
  CONSTRAINT PK_Orders PRIMARY KEY(orderid)
);

INSERT INTO dbo.Orders(orderid, orderdate, empid, custid, qty)
VALUES
  (30001, '20070802', 3, 'A', 10),
  (10001, '20071224', 2, 'A', 12),
  (10005, '20071224', 1, 'B', 20),
  (40001, '20080109', 2, 'A', 40),
  (10006, '20080118', 1, 'C', 14),
  (20001, '20080212', 2, 'B', 12),
  (40005, '20090212', 3, 'A', 10),
  (20002, '20090216', 1, 'C', 20),
  (30003, '20090418', 2, 'B', 15),
  (30004, '20070418', 3, 'C', 22),
  (30007, '20090907', 3, 'D', 30);

/*
-- Note The ability to use a single VALUES clause to insert 
-- multiple rows to a table is new in Microsoft SQL Server 2008.
-- If you’re working with an earlier version of SQL Server, 
-- substitute the single INSERT statement in Listing 7-1 with an 
-- INSERT statement per each row:

INSERT INTO dbo.Orders(orderid, orderdate, empid, custid, qty)
  VALUES(30001, '20070802', 3, 'A', 10);
INSERT INTO dbo.Orders(orderid, orderdate, empid, custid, qty)
  VALUES(10001, '20071224', 2, 'A', 12);
INSERT INTO dbo.Orders(orderid, orderdate, empid, custid, qty)
  VALUES(10005, '20071224', 1, 'B', 20);
INSERT INTO dbo.Orders(orderid, orderdate, empid, custid, qty)
  VALUES(40001, '20080109', 2, 'A', 40);
INSERT INTO dbo.Orders(orderid, orderdate, empid, custid, qty)
  VALUES(10006, '20080118', 1, 'C', 14);
INSERT INTO dbo.Orders(orderid, orderdate, empid, custid, qty)
  VALUES(20001, '20080212', 2, 'B', 12);
INSERT INTO dbo.Orders(orderid, orderdate, empid, custid, qty)
  VALUES(40005, '20090212', 3, 'A', 10);
INSERT INTO dbo.Orders(orderid, orderdate, empid, custid, qty)
  VALUES(20002, '20090216', 1, 'C', 20);
INSERT INTO dbo.Orders(orderid, orderdate, empid, custid, qty)
  VALUES(30003, '20090418', 2, 'B', 15);
INSERT INTO dbo.Orders(orderid, orderdate, empid, custid, qty)
  VALUES(30004, '20070418', 3, 'C', 22);
INSERT INTO dbo.Orders(orderid, orderdate, empid, custid, qty)
  VALUES(30007, '20090907', 3, 'D', 30);
*/

SELECT * FROM dbo.Orders;

-- Query against Orders, grouping by employee and customer
SELECT empid, custid, SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY empid, custid;

---------------------------------------------------------------------
-- Pivoting with Standard SQL
---------------------------------------------------------------------

-- Query against Orders, grouping by employee, pivoting customers,
-- aggregating sum of quantity
SELECT empid,
  SUM(CASE WHEN custid = 'A' THEN qty END) AS A,
  SUM(CASE WHEN custid = 'B' THEN qty END) AS B,
  SUM(CASE WHEN custid = 'C' THEN qty END) AS C,
  SUM(CASE WHEN custid = 'D' THEN qty END) AS D  
FROM dbo.Orders
GROUP BY empid;

---------------------------------------------------------------------
-- Pivoting with the Native T-SQL PIVOT Operator
---------------------------------------------------------------------

-- Logical equivalent of previous query using the native PIVOT operator
SELECT empid, A, B, C, D
FROM (SELECT empid, custid, qty
      FROM dbo.Orders) AS D
  PIVOT(SUM(qty) FOR custid IN(A, B, C, D)) AS P;

-- Query demonstrating the problem with implicit grouping
SELECT empid, A, B, C, D
FROM dbo.Orders
  PIVOT(SUM(qty) FOR custid IN(A, B, C, D)) AS P;

-- Logical equivalent of previous query
SELECT empid,
  SUM(CASE WHEN custid = 'A' THEN qty END) AS A,
  SUM(CASE WHEN custid = 'B' THEN qty END) AS B,
  SUM(CASE WHEN custid = 'C' THEN qty END) AS C,
  SUM(CASE WHEN custid = 'D' THEN qty END) AS D  
FROM dbo.Orders
GROUP BY orderid, orderdate, empid;

-- Query against Orders, grouping by customer, pivoting employees,
-- aggregating sum of quantity
SELECT custid, [1], [2], [3]
FROM (SELECT empid, custid, qty
      FROM dbo.Orders) AS D
  PIVOT(SUM(qty) FOR empid IN([1], [2], [3])) AS P;

---------------------------------------------------------------------
-- Unpivoting Data
---------------------------------------------------------------------

-- Code to create and populate the EmpCustOrders table
USE tempdb;

IF OBJECT_ID('dbo.EmpCustOrders', 'U') IS NOT NULL DROP TABLE dbo.EmpCustOrders;

SELECT empid, A, B, C, D
INTO dbo.EmpCustOrders
FROM (SELECT empid, custid, qty
      FROM dbo.Orders) AS D
  PIVOT(SUM(qty) FOR custid IN(A, B, C, D)) AS P;

SELECT * FROM dbo.EmpCustOrders;

---------------------------------------------------------------------
-- Unpivoting with Standard SQL
---------------------------------------------------------------------

-- Unpivot Step 1: generate copies
SELECT *
FROM dbo.EmpCustOrders
  CROSS JOIN (VALUES('A'),('B'),('C'),('D')) AS Custs(custid);

SELECT *
FROM dbo.EmpCustOrders
  CROSS JOIN (SELECT 'A' AS custid
              UNION ALL SELECT 'B'
              UNION ALL SELECT 'C'
              UNION ALL SELECT 'D') AS Custs;

-- Unpivot Step 2: extract elements
SELECT empid, custid,
  CASE custid
    WHEN 'A' THEN A
    WHEN 'B' THEN B
    WHEN 'C' THEN C
    WHEN 'D' THEN D    
  END AS qty
FROM dbo.EmpCustOrders
  CROSS JOIN (VALUES('A'),('B'),('C'),('D')) AS Custs(custid);

-- Unpivot Step 3: eliminate NULLs
SELECT *
FROM (SELECT empid, custid,
        CASE custid
          WHEN 'A' THEN A
          WHEN 'B' THEN B
          WHEN 'C' THEN C
          WHEN 'D' THEN D    
        END AS qty
      FROM dbo.EmpCustOrders
        CROSS JOIN (VALUES('A'),('B'),('C'),('D')) AS Custs(custid)) AS D
WHERE qty IS NOT NULL;

---------------------------------------------------------------------
-- Unpivoting with the Native T-SQL UNPIVOT Operator
---------------------------------------------------------------------

-- Query using the native UNPIVOT operator
SELECT empid, custid, qty
FROM dbo.EmpCustOrders
  UNPIVOT(qty FOR custid IN(A, B, C, D)) AS U;
  
---------------------------------------------------------------------
-- Grouping Sets
---------------------------------------------------------------------

-- Four queries, each with a different grouping set
SELECT empid, custid, SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY empid, custid;

SELECT empid, SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY empid;

SELECT custid, SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY custid;

SELECT SUM(qty) AS sumqty
FROM dbo.Orders;

-- Unifying result sets of four queries
SELECT empid, custid, SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY empid, custid

UNION ALL

SELECT empid, NULL, SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY empid

UNION ALL

SELECT NULL, custid, SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY custid

UNION ALL

SELECT NULL, NULL, SUM(qty) AS sumqty
FROM dbo.Orders;

---------------------------------------------------------------------
-- GROUPING SETS Subclause
---------------------------------------------------------------------

-- Using the GROUPING SETS subclause
SELECT empid, custid, SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY
  GROUPING SETS
  (
    (empid, custid),
    (empid),
    (custid),
    ()
  );

---------------------------------------------------------------------
-- CUBE Subclause
---------------------------------------------------------------------

-- Using the CUBE subclause
SELECT empid, custid, SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY CUBE(empid, custid);

SELECT empid, custid, SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY empid, custid
WITH CUBE;

---------------------------------------------------------------------
-- ROLLUP Subclause
---------------------------------------------------------------------

-- Using the ROLLUP subclause
SELECT 
  YEAR(orderdate) AS orderyear,
  MONTH(orderdate) AS ordermonth,
  DAY(orderdate) AS orderday,
  SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY ROLLUP(YEAR(orderdate), MONTH(orderdate), DAY(orderdate));

SELECT 
  YEAR(orderdate) AS orderyear,
  MONTH(orderdate) AS ordermonth,
  DAY(orderdate) AS orderday,
  SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY YEAR(orderdate), MONTH(orderdate), DAY(orderdate)
WITH ROLLUP;

---------------------------------------------------------------------
-- GROUPING and GROUPING_ID Function
---------------------------------------------------------------------

SELECT empid, custid, SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY CUBE(empid, custid);

SELECT
  GROUPING(empid) AS grpemp,
  GROUPING(custid) AS grpcust,
  empid, custid, SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY CUBE(empid, custid);

SELECT
  GROUPING_ID(empid, custid) AS groupingset,
  empid, custid, SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY CUBE(empid, custid);
