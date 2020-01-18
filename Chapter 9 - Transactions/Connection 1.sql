-- Connection 1
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

BEGIN TRAN;

  SELECT productid, unitprice
  FROM Production.Products
  WHERE productid = 2;

/*
 productid     unitprice    
 ------------  ------------ 
 2             19       
*/