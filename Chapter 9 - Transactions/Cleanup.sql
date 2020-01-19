-- Cleanup
UPDATE Production.Products
  SET unitprice = 19.00
WHERE productid = 2;

-- Close all connections
