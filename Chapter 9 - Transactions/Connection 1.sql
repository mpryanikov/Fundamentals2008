-- Connection 1, Step 2
  UPDATE Production.Products
    SET unitprice = 20.00
  WHERE productid = 2;
  
COMMIT TRAN;

/*
 1 ������(�) �����������(����) ��������
*/