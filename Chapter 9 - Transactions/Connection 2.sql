-- Connection 2
-- Stop, then set the LOCK_TIMEOUT, then retry
SET LOCK_TIMEOUT 5000;

SELECT productid, unitprice
FROM Production.Products
WHERE productid = 2;

/*
>[������] ������ ��������: 1-7 ----------------------
 ��������� ����� �������� ������� �� ����������.
 ���������: 1222, �������: 16, ���������: 51, ���������: , ������: 5 

 [���������: 18.01.2020 20:50:39] [����������: 5�] 

*/