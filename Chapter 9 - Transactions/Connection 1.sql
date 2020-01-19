-- Connection 1
BEGIN TRAN;

  UPDATE Production.Products
    SET unitprice = unitprice + 1.00
  WHERE productid = 2;

  SELECT productid, unitprice
  FROM Production.Products
  WHERE productid = 2;

/*
 productid     unitprice    
 ------------  ------------ 
 2             22           
*/