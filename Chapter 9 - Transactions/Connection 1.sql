-- Connection 1
  SELECT productid, unitprice
  FROM Production.Products
  WHERE productid = 2;

COMMIT TRAN;

/*
 productid     unitprice    
 ------------  ------------ 
 2             19       
*/