
--1.По каждой книге посчитать стоимость заказанного, проданного и отгруженного по месяцам в 2025 году. Выводить всё в одном селекте.
SELECT 
    b.Book_ID,
    b.Book,
    YEAR(o.Date_of_Order) AS [Year],
    MONTH(o.Date_of_Order) AS [Month],
    ISNULL(SUM(od.Qty_ord * od.Price_RUR), 0) AS Ordered_Cost,
    ISNULL(SUM(CASE 
        WHEN o.Pmnt_RUR = o.Sum_RUR 
        THEN od.Qty_ord * od.Price_RUR 
        ELSE 0 
    END), 0) AS Sold_Cost,
    ISNULL(SUM(od.Qty_out * od.Price_RUR), 0) AS Shipped_Cost
FROM Books b
LEFT JOIN Orders_data od ON b.Book_ID = od.Book_ID
LEFT JOIN Orders o ON od.ndoc = o.ndoc
WHERE YEAR(o.Date_of_Order) = 2025 OR o.Date_of_Order IS NULL
GROUP BY 
    b.Book_ID,
    b.Book,
    YEAR(o.Date_of_Order),
    MONTH(o.Date_of_Order)
ORDER BY 
    b.Book_ID,
    YEAR(o.Date_of_Order),
    MONTH(o.Date_of_Order);


--2.По каждому разделу посчитать среднюю стоимость заказанного товара в день за последний месяц. Учитывать и те дни, 
--когда ни одна книга из данного раздела заказана не была, но были заказаны книги из каких-либо других разделов, 
--но не учитывать те дни, когда книги не заказывались вообще. Средняя стоимость = суммарная стоимость/колво дней.

DECLARE @LastMonthStart DATETIME;
DECLARE @LastMonthEnd DATETIME;

-- Находим первый день последнего месяца с заказами
SELECT @LastMonthStart = DATEFROMPARTS(YEAR(MAX(Date_of_Order)), MONTH(MAX(Date_of_Order)), 1)
FROM Orders;

-- Находим последний день этого месяца
SET @LastMonthEnd = EOMONTH(@LastMonthStart);

SELECT 
    s.Section_ID,
    s.Section,
    ISNULL(
        CAST(SUM(od.Qty_ord * od.Price_RUR) AS FLOAT) / 
        NULLIF(COUNT(DISTINCT CAST(o.Date_of_Order AS DATE)), 0),
        0
    ) AS Avg_Daily_Cost
FROM Sections s
LEFT JOIN Books b ON s.Section_ID = b.Section_ID
LEFT JOIN Orders_data od ON b.Book_ID = od.Book_ID
LEFT JOIN Orders o ON od.ndoc = o.ndoc
WHERE (o.Date_of_Order >= @LastMonthStart AND o.Date_of_Order <= @LastMonthEnd)
   OR (o.ndoc IS NULL)
GROUP BY 
    s.Section_ID,
    s.Section
ORDER BY 
    s.Section_ID;


--3. По каждому автору вывести его рейтинг за последний месяц. У автора с максимальной суммарной стоимостью заказанного рейтинг = 1,
--у второго по суммарной стоимости заказанного рейтинг = 2 и тд. В случае если существует несколько авторов с одинаковой стоимостью, 
--рейтинг по каждому равен максимальному для них возможному. Например, суммарная стоимость по 1-ому автору = 100, по двум следующим 50, 
--рейтинг 1-ого равен единице, рейтинги 2-ого и 3-его равны трем.
DECLARE @LastMonthStart2 DATETIME;
DECLARE @LastMonthEnd2 DATETIME;

-- Находим первый день последнего месяца с заказами
SELECT @LastMonthStart2 = DATEFROMPARTS(YEAR(MAX(Date_of_Order)), MONTH(MAX(Date_of_Order)), 1)
FROM Orders;

-- Находим последний день этого месяца
SET @LastMonthEnd2 = EOMONTH(@LastMonthStart2);

WITH Author_Costs AS (
    SELECT 
        a.Author_ID,
        a.Surname + ' ' + a.Name AS Author_Name,
        ISNULL(SUM(od.Qty_ord * od.Price_RUR), 0) AS Total_Cost
    FROM Authors a
    LEFT JOIN Books b ON a.Author_ID = b.Author_ID
    LEFT JOIN Orders_data od ON b.Book_ID = od.Book_ID
    LEFT JOIN Orders o ON od.ndoc = o.ndoc
    WHERE o.Date_of_Order >= @LastMonthStart2 
      AND o.Date_of_Order <= @LastMonthEnd2
    GROUP BY 
        a.Author_ID,
        a.Surname,
        a.Name
)
SELECT 
    Author_ID,
    Author_Name,
    DENSE_RANK() OVER (ORDER BY Total_Cost DESC) AS Rating,
    Total_Cost
FROM Author_Costs
WHERE Total_Cost > 0
ORDER BY 
    Rating,
    Author_Name;

--4.Вывести по каждому покупателю (включая тех, кто не делал заказы) суммарный оборот за последний месяц. 
--Оборот = суммарная стоимость оплаченного. Для тех, кто заказы не делал, выводить 0.

DECLARE @LastMonthStart DATETIME;
DECLARE @LastMonthEnd DATETIME;

-- Находим первый и последний день последнего месяца с заказами
SELECT @LastMonthStart = DATEFROMPARTS(YEAR(MAX(Date_of_Order)), MONTH(MAX(Date_of_Order)), 1)
FROM Orders;

SET @LastMonthEnd = EOMONTH(@LastMonthStart);

SELECT 
    c.Cust_ID,
    c.Customer,
    ISNULL(SUM(o.Pmnt_RUR), 0) AS Total_Revenue
FROM Customers c
LEFT JOIN Orders o ON c.Cust_ID = o.Cust_ID 
    AND o.Date_of_Order >= @LastMonthStart 
    AND o.Date_of_Order <= @LastMonthEnd
GROUP BY 
    c.Cust_ID,
    c.Customer
ORDER BY 
    Total_Revenue DESC,
    c.Customer;

--5.Вывести книги, которые есть в остатке на складе на сейчас, но их не ставили в заказ после 01.10.25.

SELECT 
    b.Book_ID,
    b.Book,
    a.Surname + ' ' + a.Name AS Author,
    s.Qty_in_Stock,
    s.Qty_rsrv
FROM Books b
INNER JOIN Stock s ON b.Book_ID = s.Book_ID
INNER JOIN Authors a ON b.Author_ID = a.Author_ID
WHERE s.Qty_in_Stock > 0
  AND b.Book_ID NOT IN (
      SELECT DISTINCT od.Book_ID
      FROM Orders_data od
      INNER JOIN Orders o ON od.ndoc = o.ndoc
      WHERE o.Date_of_Order >= '20251001'
  )
ORDER BY 
    b.Book_ID;

--6.Вывести покупателя и такие его книги, что покупатель заказывал эти книги до 01.10.25,
--но не заказывал после 01.10.25, при этом эти книги есть в наличии (остаток > 0).

SELECT 
    c.Cust_ID,
    c.Customer,
    b.Book_ID,
    b.Book,
    a.Surname + ' ' + a.Name AS Author,
    s.Qty_in_Stock
FROM Customers c
INNER JOIN Orders o_before ON c.Cust_ID = o_before.Cust_ID
INNER JOIN Orders_data od_before ON o_before.ndoc = od_before.ndoc
INNER JOIN Books b ON od_before.Book_ID = b.Book_ID
INNER JOIN Authors a ON b.Author_ID = a.Author_ID
INNER JOIN Stock s ON b.Book_ID = s.Book_ID
WHERE o_before.Date_of_Order < '20251001'
  AND s.Qty_in_Stock > 0
  AND b.Book_ID NOT IN (
      SELECT DISTINCT od_after.Book_ID
      FROM Orders_data od_after
      INNER JOIN Orders o_after ON od_after.ndoc = o_after.ndoc
      WHERE o_after.Cust_ID = c.Cust_ID
        AND o_after.Date_of_Order >= '20251001'
  )
GROUP BY 
    c.Cust_ID,
    c.Customer,
    b.Book_ID,
    b.Book,
    a.Surname,
    a.Name,
    s.Qty_in_Stock
ORDER BY 
    c.Cust_ID,
    b.Book_ID;

--7.Вывести долю товара в резерве (доля в стоимости и доля от штук) от суммарного физического остатка на текущий момент. 
--Цена – по текущей цене книги.

SELECT 
    b.Book_ID,
    b.Book,
    a.Surname + ' ' + a.Name AS Author,
    s.Qty_in_Stock,
    s.Qty_rsrv,
    b.Price_RUR,
    CAST(ROUND(
        CAST(s.Qty_rsrv AS FLOAT) / NULLIF(s.Qty_in_Stock, 0) * 100, 
        2
    ) AS DECIMAL(5,2)) AS Qty_Reserve_Percent,
    CAST(ROUND(
        (s.Qty_rsrv * b.Price_RUR) / NULLIF(s.Qty_in_Stock * b.Price_RUR, 0) * 100, 
        2
    ) AS DECIMAL(5,2)) AS Cost_Reserve_Percent,
    s.Qty_rsrv * b.Price_RUR AS Reserved_Cost,
    s.Qty_in_Stock * b.Price_RUR AS Total_Stock_Cost
FROM Books b
INNER JOIN Stock s ON b.Book_ID = s.Book_ID
INNER JOIN Authors a ON b.Author_ID = a.Author_ID
WHERE s.Qty_in_Stock > 0
ORDER BY 
    b.Book_ID;


--8.Вывести покупателей, которые забрали книги, но не оплатили заказ, и тех, которые оплатили заказ, но книги не забрали. 
--Для таких покупателей кроме названия вывести: 1) стоимость отпущенных книг, за которые не заплатили, 2) суммарную оплату за книги, 
--которые они еще не забрали. Вывод должен быть в одном рекордсете с дополнительным комментарием, 
--позволяющим отделить один тип покупателей от другого.

-- Тип 1: Забрали, но не оплатили
SELECT 
    c.Cust_ID,
    c.Customer,
    'Забрал товар, но не оплатил' AS Customer_Type,
    SUM(od.Qty_out * od.Price_RUR) AS Amount_Info,
    0 AS Additional_Info
FROM Customers c
INNER JOIN Orders o ON c.Cust_ID = o.Cust_ID
INNER JOIN Orders_data od ON o.ndoc = od.ndoc
WHERE o.Pmnt_RUR = 0  -- Не оплачено
  AND od.Qty_out > 0  -- Отпущено
GROUP BY 
    c.Cust_ID,
    c.Customer

UNION ALL

-- Тип 2: Оплатили, но не забрали
SELECT 
    c.Cust_ID,
    c.Customer,
    'Оплатил, но не забрал товар' AS Customer_Type,
    SUM(
        CASE 
            WHEN od.Qty_out = 0 THEN od.Qty_ord * od.Price_RUR 
            ELSE 0 
        END
    ) AS Amount_Info,
    0 AS Additional_Info
FROM Customers c
INNER JOIN Orders o ON c.Cust_ID = o.Cust_ID
INNER JOIN Orders_data od ON o.ndoc = od.ndoc
WHERE o.Pmnt_RUR = o.Sum_RUR  -- Полностью оплачено
  AND od.Qty_out = 0           -- Ничего не отпущено
GROUP BY 
    c.Cust_ID,
    c.Customer

ORDER BY 
    Cust_ID,
    Customer_Type;


--9.По коду книги, количеству, покупателю_ID показывать, возможен ли заказ этого товара с указанным количеством. Код книги,
--колво, код покупателя передаются параметрами. Запрос должен возвращать 0, если не возможен, иначе 1. 
--(то есть покупатель хочет заказать определенную книгу, мы должны сказать, может он это сделать или нет. Подумайте, в каком случае «нет»).

DECLARE @BookID INT = 1;           -- Код книги (параметр)
DECLARE @Qty INT = 2;              -- Количество (параметр)
DECLARE @CustID INT = 1;           -- ID покупателя (параметр)

SELECT 
    CASE 
        WHEN (s.Qty_in_Stock - ISNULL(s.Qty_rsrv, 0)) >= @Qty
         AND c.Balance >= (b.Price_RUR * @Qty * 0.1)
        THEN 1
        ELSE 0
    END AS Can_Order
FROM Books b
INNER JOIN Stock s ON b.Book_ID = s.Book_ID
INNER JOIN Customers c ON c.Cust_ID = @CustID
WHERE b.Book_ID = @BookID;


--10.Написать запрос, который по номеру документа проставляет итоговое значение Sum_RUR в Orders, 
--равное суммарной стоимости всех книг в Orders_data.

DECLARE @DocNum INT = 1;  -- Номер документа (параметр)

UPDATE Orders
SET Sum_RUR = (
    SELECT ISNULL(SUM(od.Qty_ord * od.Price_RUR), 0)
    FROM Orders_data od
    WHERE od.ndoc = @DocNum
)
WHERE ndoc = @DocNum;

-- Вывод для проверки
SELECT 
    ndoc,
    Date_of_Order,
    Cust_ID,
    Sum_RUR,
    Pmnt_RUR
FROM Orders
WHERE ndoc = @DocNum;

--11.По номеру заказа определять, можно ли полностью оплатить его из баланса покупателя. 
--Запрос должен возвращать 1 – если можно, 0 – иначе.

DECLARE @OrderNum INT = 1;  -- Номер заказа (параметр)

SELECT 
    CASE 
        WHEN c.Balance >= o.Sum_RUR
        THEN 1
        ELSE 0
    END AS Can_Pay_From_Balance
FROM Orders o
INNER JOIN Customers c ON o.Cust_ID = c.Cust_ID
WHERE o.ndoc = @OrderNum;

--12.Написать запрос, который по номеру заказа проставляет оплату в заказе (если это можно сделать) и обновляет баланс покупателя. 
--Желательно в одном предложении (чтобы в случае ошибки автоматически откатывались обе транзакции), но можно сделать и разными запросами.

DECLARE @OrderNum INT = 2;  -- Номер заказа (параметр)

BEGIN TRANSACTION;

BEGIN TRY
    -- Проверяем, что заказ не оплачен и баланс достаточен
    DECLARE @CustID INT;
    DECLARE @OrderSum DECIMAL(10, 2);
    DECLARE @CustBalance DECIMAL(10, 2);
    
    -- Получаем данные заказа
    SELECT 
        @CustID = o.Cust_ID,
        @OrderSum = o.Sum_RUR
    FROM Orders o
    WHERE o.ndoc = @OrderNum;
    
    -- Проверяем, что заказ существует
    IF @CustID IS NULL
    BEGIN
        THROW 50001, 'Заказ не найден', 1;
    END
    
    -- Получаем баланс покупателя
    SELECT @CustBalance = Balance
    FROM Customers
    WHERE Cust_ID = @CustID;
    
    -- Проверяем, что баланса достаточно и заказ еще не оплачен
    IF (SELECT Pmnt_RUR FROM Orders WHERE ndoc = @OrderNum) != 0
    BEGIN
        THROW 50002, 'Заказ уже оплачен', 1;
    END
    
    IF @CustBalance < @OrderSum
    BEGIN
        THROW 50003, 'Недостаточно средств на балансе', 1;
    END
    
    -- Обновляем оплату в заказе
    UPDATE Orders
    SET Pmnt_RUR = Sum_RUR
    WHERE ndoc = @OrderNum;
    
    -- Обновляем баланс покупателя
    UPDATE Customers
    SET Balance = Balance - @OrderSum
    WHERE Cust_ID = @CustID;
    
    COMMIT TRANSACTION;
    
    -- Вывод подтверждения
    SELECT 
        ndoc,
        Cust_ID,
        Sum_RUR,
        Pmnt_RUR,
        'Оплачено успешно' AS Status
    FROM Orders
    WHERE ndoc = @OrderNum;
    
    SELECT 
        Cust_ID,
        Customer,
        Balance,
        'Баланс обновлен' AS Status
    FROM Customers
    WHERE Cust_ID = @CustID;

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    
    -- Вывод ошибки
    SELECT 
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_MESSAGE() AS ErrorMessage,
        'Транзакция отменена' AS Status;
END CATCH;

--13.Написать запрос, который по заданному номеру заказа изменяет поле «Qty_rsrv» в остатках по каждому товару из заказа на величину 
--заказанного. (То есть запрос, который по заказу резервирует товар, чтобы количество, которое заказал наш покупатель,
--не было доступно для заказа другим покупателям, но не забываем, что товар покупатель еще со склада не забрал).
--Не забывайте, что в одном заказе одна книга может встречаться в разных строках, проверьте, что Ваш запрос работает правильно.

DECLARE @OrderNum INT = 7;  -- Номер заказа (параметр)

-- Временная таблица для группировки товаров в заказе
-- (на случай, если одна книга встречается в разных строках)
DECLARE @ReserveData TABLE (
    Book_ID INT,
    Total_Qty INT
);

-- Заполняем временную таблицу с суммой количества по каждой книге
INSERT INTO @ReserveData
SELECT 
    od.Book_ID,
    SUM(od.Qty_ord) AS Total_Qty
FROM Orders_data od
WHERE od.ndoc = @OrderNum
GROUP BY od.Book_ID;

-- Проверяем, что заказ существует
IF NOT EXISTS (SELECT 1 FROM Orders WHERE ndoc = @OrderNum)
BEGIN
    RAISERROR('Заказ не найден', 16, 1);
END
ELSE
BEGIN
    -- Обновляем резервы по каждому товару
    UPDATE Stock
    SET Qty_rsrv = Qty_rsrv + rd.Total_Qty
    FROM Stock s
    INNER JOIN @ReserveData rd ON s.Book_ID = rd.Book_ID
    WHERE rd.Book_ID = s.Book_ID;
    
    -- Вывод для проверки
    SELECT 
        od.Book_ID,
        b.Book,
        SUM(od.Qty_ord) AS Qty_Reserved,
        s.Qty_in_Stock,
        s.Qty_rsrv,
        (s.Qty_in_Stock - s.Qty_rsrv) AS Qty_Available
    FROM Orders_data od
    INNER JOIN Books b ON od.Book_ID = b.Book_ID
    INNER JOIN Stock s ON b.Book_ID = s.Book_ID
    WHERE od.ndoc = @OrderNum
    GROUP BY 
        od.Book_ID,
        b.Book,
        s.Qty_in_Stock,
        s.Qty_rsrv
    ORDER BY od.Book_ID;
END

--14.Написать запрос, который по заданному номеру заказа изменяет поле «Qty_in_stock» в остатках по каждой книге из заказа на величину 
--отпущенного, а также соответствующим образом изменяет поле «Qty_rsrv». (То есть покупатель забирает зарезервированный товар со склада, 
--что при этом должно произойти с остатками этого товара на складе?) Комментарий про одинаковые книги в одном заказе в силе.

DECLARE @OrderNum INT = 2;  -- Номер заказа (параметр)

-- Сначала выводим информацию о заказе для диагностики
SELECT 
    '=== ИНФОРМАЦИЯ О ЗАКАЗЕ ===' AS Section;

SELECT 
    o.ndoc,
    o.Date_of_Order,
    c.Customer,
    o.Sum_RUR,
    o.Pmnt_RUR
FROM Orders o
INNER JOIN Customers c ON o.Cust_ID = c.Cust_ID
WHERE o.ndoc = @OrderNum;

-- Выводим все строки заказа с информацией о количестве
SELECT 
    '=== СТРОКИ ЗАКАЗА ===' AS Section;

SELECT 
    od.ndoc,
    od.npos,
    od.Book_ID,
    b.Book,
    od.Qty_ord,
    od.Qty_out,
    od.Price_RUR
FROM Orders_data od
INNER JOIN Books b ON od.Book_ID = b.Book_ID
WHERE od.ndoc = @OrderNum
ORDER BY od.npos;

-- Проверяем, есть ли отпущенный товар
IF NOT EXISTS (SELECT 1 FROM Orders WHERE ndoc = @OrderNum)
BEGIN
    SELECT 'ОШИБКА: Заказ не найден' AS Result;
END
ELSE IF NOT EXISTS (SELECT 1 FROM Orders_data WHERE ndoc = @OrderNum AND Qty_out > 0)
BEGIN
    SELECT 
        'ИНФОРМАЦИЯ: В заказе ' + CAST(@OrderNum AS VARCHAR(10)) + 
        ' нет отпущенного товара (все Qty_out = 0)' AS Result,
        'Выберите заказ с отпущенным товаром (Qty_out > 0)' AS Recommendation;
    
    -- Выводим заказы с отпущенным товаром
    SELECT 
        o.ndoc,
        o.Date_of_Order,
        c.Customer,
        COUNT(DISTINCT od.Book_ID) AS Book_Count,
        SUM(od.Qty_out) AS Total_Qty_Out
    FROM Orders o
    INNER JOIN Customers c ON o.Cust_ID = c.Cust_ID
    INNER JOIN Orders_data od ON o.ndoc = od.ndoc
    WHERE od.Qty_out > 0
    GROUP BY 
        o.ndoc,
        o.Date_of_Order,
        c.Customer
    ORDER BY o.ndoc;
END
ELSE
BEGIN
    -- Временная таблица для группировки отпущенного товара
    DECLARE @ShippedData TABLE (
        Book_ID INT,
        Total_Qty_Out INT
    );

    -- Заполняем временную таблицу с суммой отпущенного по каждой книге
    INSERT INTO @ShippedData
    SELECT 
        od.Book_ID,
        SUM(od.Qty_out) AS Total_Qty_Out
    FROM Orders_data od
    WHERE od.ndoc = @OrderNum
      AND od.Qty_out > 0  -- Только отпущенный товар
    GROUP BY od.Book_ID;

    -- Обновляем остатки по каждому товару:
    -- 1. Уменьшаем Qty_in_Stock на количество отпущенного
    -- 2. Уменьшаем Qty_rsrv на количество отпущенного (товар больше не в резерве)
    UPDATE Stock
    SET 
        Qty_in_Stock = Qty_in_Stock - sd.Total_Qty_Out,
        Qty_rsrv = Qty_rsrv - sd.Total_Qty_Out
    FROM Stock s
    INNER JOIN @ShippedData sd ON s.Book_ID = sd.Book_ID
    WHERE s.Book_ID = sd.Book_ID;
    
    SELECT '=== РЕЗУЛЬТАТ ОБНОВЛЕНИЯ ===' AS Section;
    
    -- Вывод для проверки
    SELECT 
        od.Book_ID,
        b.Book,
        SUM(od.Qty_ord) AS Qty_Ordered,
        SUM(od.Qty_out) AS Qty_Shipped,
        s.Qty_in_Stock,
        s.Qty_rsrv,
        (s.Qty_in_Stock - s.Qty_rsrv) AS Qty_Available
    FROM Orders_data od
    INNER JOIN Books b ON od.Book_ID = b.Book_ID
    INNER JOIN Stock s ON b.Book_ID = s.Book_ID
    WHERE od.ndoc = @OrderNum
    GROUP BY 
        od.Book_ID,
        b.Book,
        s.Qty_in_Stock,
        s.Qty_rsrv
    ORDER BY od.Book_ID;
END


--15.Написать запрос, который по всем неоплаченным заказам за вчера, возвращает неотпущенные книги из резерва в продажу. 
--(Покупатель не оплатил и не забрал книги из своего заказа, модель бизнес-процесса в п.15 говорит, что нужно вернуть такие книги 
--в свободный доступ для всех покупателей. Какие поля нужно изменить?)

DECLARE @YesterdayStart DATETIME;
DECLARE @YesterdayEnd DATETIME;

-- Вычисляем дату вчера (начало и конец дня)
SET @YesterdayStart = CAST(DATEADD(DAY, -1, CAST(GETDATE() AS DATE)) AS DATETIME);
SET @YesterdayEnd = DATEADD(SECOND, -1, DATEADD(DAY, 1, @YesterdayStart));

-- Временная таблица для товаров, которые нужно вернуть в резерв
DECLARE @ReturnToSaleData TABLE (
    Book_ID INT,
    Total_Qty_To_Return INT
);

-- Заполняем временную таблицу товарами для возврата из резерва
INSERT INTO @ReturnToSaleData
SELECT 
    od.Book_ID,
    SUM(od.Qty_ord) AS Total_Qty_To_Return
FROM Orders_data od
INNER JOIN Orders o ON od.ndoc = o.ndoc
WHERE o.Date_of_Order >= @YesterdayStart
  AND o.Date_of_Order <= @YesterdayEnd
  AND (o.Pmnt_RUR = 0 OR o.Pmnt_RUR < o.Sum_RUR)  -- Не оплачено или частично оплачено
  AND od.Qty_out = 0  -- Товар не отпущен
GROUP BY od.Book_ID;

-- Проверяем, что есть товары для возврата
IF NOT EXISTS (SELECT 1 FROM @ReturnToSaleData)
BEGIN
    SELECT 'Нет неоплаченных заказов за вчера с неотпущенным товаром' AS Message;
END
ELSE
BEGIN
    -- Возвращаем товары в свободный доступ
    -- Уменьшаем Qty_rsrv на количество возвращаемого товара
    UPDATE Stock
    SET Qty_rsrv = Qty_rsrv - rsd.Total_Qty_To_Return
    FROM Stock s
    INNER JOIN @ReturnToSaleData rsd ON s.Book_ID = rsd.Book_ID
    WHERE s.Book_ID = rsd.Book_ID;
    
    -- Вывод для проверки - какой товар был возвращен
    SELECT 
        od.Book_ID,
        b.Book,
        SUM(od.Qty_ord) AS Qty_Returned_From_Reserve,
        s.Qty_in_Stock,
        s.Qty_rsrv,
        (s.Qty_in_Stock - s.Qty_rsrv) AS Qty_Now_Available,
        o.ndoc AS Order_ID,
        o.Date_of_Order,
        c.Customer,
        o.Sum_RUR,
        o.Pmnt_RUR
    FROM Orders_data od
    INNER JOIN Orders o ON od.ndoc = o.ndoc
    INNER JOIN Customers c ON o.Cust_ID = c.Cust_ID
    INNER JOIN Books b ON od.Book_ID = b.Book_ID
    INNER JOIN Stock s ON b.Book_ID = s.Book_ID
    WHERE o.Date_of_Order >= @YesterdayStart
      AND o.Date_of_Order <= @YesterdayEnd
      AND (o.Pmnt_RUR = 0 OR o.Pmnt_RUR < o.Sum_RUR)
      AND od.Qty_out = 0
    GROUP BY 
        od.Book_ID,
        b.Book,
        s.Qty_in_Stock,
        s.Qty_rsrv,
        o.ndoc,
        o.Date_of_Order,
        c.Customer,
        o.Sum_RUR,
        o.Pmnt_RUR
    ORDER BY 
        o.ndoc,
        od.Book_ID;
END

