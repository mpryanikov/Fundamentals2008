-- Connection 2
INSERT INTO Production.Products
    (productname, supplierid, categoryid,
     unitprice, discontinued)
  VALUES('Product ABCDE', 1, 1, 20.00, 0);

/*
spid     blocking_session_id     command     sql_handle                                                                                database_id     wait_type     wait_time     wait_resource                           
 -------  ----------------------  ----------  ----------------------------------------------------------------------------------------  --------------  ------------  ------------  --------------------------------------- 
 56       55                      INSERT      0200000032bfd722b2073dd7ac86668464ce97ec45e12bf20000000000000000000000000000000000000000  9               LCK_M_RIn_NL  27943         KEY: 9:72057594041073664 (ffffffffffff) 
*/