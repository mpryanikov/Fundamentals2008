-- Connection 2
-- Remove timeout
SET LOCK_TIMEOUT -1;

SELECT productid, unitprice
FROM Production.Products
WHERE productid = 2;