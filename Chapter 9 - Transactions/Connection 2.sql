-- Connection 2
BEGIN TRAN;

  UPDATE Sales.OrderDetails
    SET unitprice = unitprice + 1.00
  WHERE productid = 2;