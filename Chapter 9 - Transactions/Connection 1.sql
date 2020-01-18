/*
-- Connection 1
BEGIN TRAN;

  UPDATE Production.Products
    SET unitprice = unitprice + 1.00
  WHERE productid = 2;

  SELECT productid, unitprice
  FROM Production.Products
  WHERE productid = 2;
*/

/*
 1 запись(и) поддающаяся(иеся) действию 

 productid     unitprice    
 ------------  ------------ 
 2             21           

 1 запись(ей) выделено [Извлечь (fetch) MetaData: 0мс] [Извлечь данные: 15мс] 
*/

COMMIT TRAN;