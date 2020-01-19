-- Connection 2
SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

BEGIN TRAN;

  SELECT productid, unitprice
  FROM Production.Products
  WHERE productid = 2;

/*
 productid     unitprice    
 ------------  ------------ 
 2             21      
*/