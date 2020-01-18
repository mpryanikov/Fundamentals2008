-- Connection 2
-- Stop, then set the LOCK_TIMEOUT, then retry
SET LOCK_TIMEOUT 5000;

SELECT productid, unitprice
FROM Production.Products
WHERE productid = 2;

/*
>[Ошибка] Строки сценария: 1-7 ----------------------
 Превышено время ожидания запроса на блокировку.
 Сообщение: 1222, Уровень: 16, Состояние: 51, Процедура: , Строка: 5 

 [Выполнено: 18.01.2020 20:50:39] [Выполнение: 5с] 

*/