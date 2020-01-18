-- Cleanup
DELETE FROM Production.Products
WHERE productid > 77;

DBCC CHECKIDENT ('Production.Products', RESEED, 77);

-- In all connections issue:
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;