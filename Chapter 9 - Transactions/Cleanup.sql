-- Cleanup
UPDATE Production.Products
  SET unitprice = 19.00
WHERE productid = 2;

-- Close all connections

-- Make sure you're back in default mode
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- Change database options to default
ALTER DATABASE TSQLFundamentals2008 SET ALLOW_SNAPSHOT_ISOLATION OFF;
ALTER DATABASE TSQLFundamentals2008 SET READ_COMMITTED_SNAPSHOT OFF;