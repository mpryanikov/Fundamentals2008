-- Connection 2

  SELECT productid, unitprice
  FROM Production.Products
  WHERE productid = 2;

COMMIT TRAN;

/*
 productid     unitprice    
 ------------  ------------ 
 2             20      
*/