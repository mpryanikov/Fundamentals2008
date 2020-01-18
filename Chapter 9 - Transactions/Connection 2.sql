-- Connection 2
UPDATE Production.Products
  SET unitprice = unitprice + 1.00
WHERE productid = 2;

/*
spid     blocking_session_id     command     sql_handle                                                                                database_id     wait_type     wait_time     wait_resource                           
 -------  ----------------------  ----------  ----------------------------------------------------------------------------------------  --------------  ------------  ------------  --------------------------------------- 
 55       53                      UPDATE      020000008cff0337f7d8404c59c383fc659af9614494a08b0000000000000000000000000000000000000000  9               LCK_M_X       6571          KEY: 9:72057594041073664 (61a06abd401c) 
*/