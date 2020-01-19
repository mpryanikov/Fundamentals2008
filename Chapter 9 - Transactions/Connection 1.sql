-- Connection 1
BEGIN TRAN;

  UPDATE Production.Products
    SET unitprice = unitprice + 1.00
  WHERE productid = 2;