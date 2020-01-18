-- Connection 1
  SELECT productid, productname, categoryid, unitprice
  FROM Production.Products
  WHERE categoryid = 1;

COMMIT TRAN;

/*
 productid     productname     categoryid     unitprice    
 ------------  --------------  -------------  ------------ 
 1             Product HHYDP   1              18           
 2             Product RECZE   1              21           
 24            Product QOGNU   1              4,5          
 34            Product SWNJY   1              14           
 35            Product NEVTJ   1              18           
 38            Product QDOMO   1              263,5        
 39            Product LSOFL   1              18           
 43            Product ZZZHR   1              46           
 67            Product XLXQF   1              14           
 70            Product TOONT   1              15           
 75            Product BWRLG   1              7,75         
 76            Product JYGFE   1              18   
*/