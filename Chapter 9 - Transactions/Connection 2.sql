-- Connection 2
BEGIN TRAN;

  SELECT productid, unitprice
  FROM Production.Products
  WHERE productid = 2;

/*
 productid     unitprice    
 ------------  ------------ 
 2             19    
*/