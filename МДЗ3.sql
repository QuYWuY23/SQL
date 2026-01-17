DROP TABLE IF EXISTS Docs_Data;
DROP TABLE IF EXISTS Docs;
DROP TABLE IF EXISTS Goods;
DROP TABLE IF EXISTS Customers;

-- Создание таблицы Customers (Клиенты)
CREATE TABLE Customers (
    Cust_ID INT IDENTITY(1,1) PRIMARY KEY,
    Customer NVARCHAR(100) NOT NULL,
    City NVARCHAR(100) NOT NULL
);

-- Создание таблицы Goods (Товары)
CREATE TABLE Goods (
    Good_ID INT IDENTITY(1,1) PRIMARY KEY,
    Good NVARCHAR(100) NOT NULL,
    Price DECIMAL(10, 2) NOT NULL,
    QtyInStock INT NOT NULL,
    Volume DECIMAL(10, 2),
    Mass DECIMAL(10, 2)
);

-- Создание таблицы Docs (Документы)
CREATE TABLE Docs (
    DocNum INT IDENTITY(1,1) PRIMARY KEY,
    Data DATE NOT NULL,
    Cust_ID INT NOT NULL,
    Total DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (Cust_ID) REFERENCES Customers(Cust_ID)
);

-- Создание таблицы Docs_Data (Данные документов)
CREATE TABLE Docs_Data (
    DocNum INT NOT NULL,
    Good_ID INT NOT NULL,
    Price DECIMAL(10, 2) NOT NULL,
    Qty INT NOT NULL,
    PRIMARY KEY (DocNum, Good_ID),
    FOREIGN KEY (DocNum) REFERENCES Docs(DocNum),
    FOREIGN KEY (Good_ID) REFERENCES Goods(Good_ID)
);

-- Заполнение таблицы Customers
INSERT INTO Customers (Customer, City) VALUES
('Alpha Corporation', 'New York'),
('Beta Enterprises', 'Los Angeles'),
('Gamma Solutions', 'Chicago'),
('Delta Technologies', 'Houston'),
('Epsilon Industries', 'Phoenix'),
('Zeta Global', 'Philadelphia'),
('Eta Systems', 'San Antonio'),
('Theta Analytics', 'San Diego'),
('Iota Services', 'Dallas'),
('Kappa Consulting', 'San Jose'),
('Lambda Logistics', 'Austin'),
('Mu Investments', 'Jacksonville');

-- Заполнение таблицы Goods
INSERT INTO Goods (Good, Price, QtyInStock, Volume, Mass) VALUES
('Laptop Dell XPS 15', 1500.00, 30, 0.018, 2.0),
('Monitor LG 27" 4K', 450.00, 50, 0.040, 5.5),
('Mechanical Keyboard RGB', 120.00, 200, 0.005, 1.0),
('Wireless Mouse Logitech', 35.00, 250, 0.002, 0.15),
('Printer Canon ImageRunner', 800.00, 20, 0.055, 15.0),
('WiFi Router ASUS RT-AX88U', 80.00, 100, 0.003, 0.5),
('Webcam HD Razer Kiyo', 150.00, 80, 0.002, 0.3),
('Headphones Sony WH-1000XM4', 350.00, 120, 0.004, 0.25),
('USB Flash Drive 128GB', 25.00, 400, 0.00015, 0.05),
('External SSD 4TB Samsung', 200.00, 70, 0.0025, 0.35),
('Network Switch 24-Port', 150.00, 45, 0.004, 0.8),
('UPS CyberPower 1500VA', 300.00, 25, 0.030, 10.0);

-- Заполнение таблицы Docs
INSERT INTO Docs (Data, Cust_ID, Total) VALUES
('2025-11-01', 1, 2550.00),
('2025-11-02', 2, 1350.00),
('2025-11-03', 3, 3200.00),
('2025-11-05', 4, 800.00),
('2025-11-07', 5, 2100.00),
('2025-11-08', 6, 4200.00),
('2025-11-10', 7, 1050.00),
('2025-11-12', 8, 2450.00),
('2025-11-15', 9, 3700.00),
('2025-11-18', 10, 1700.00),
('2025-11-20', 11, 2900.00),
('2025-11-22', 12, 1200.00);

-- Заполнение таблицы Docs_Data
INSERT INTO Docs_Data (DocNum, Good_ID, Price, Qty) VALUES
-- Document 1
(1, 1, 1500.00, 1),
(1, 3, 120.00, 3),
(1, 4, 35.00, 6),
(1, 9, 25.00, 8),
-- Document 2
(2, 2, 450.00, 3),
-- Document 3
(3, 1, 1500.00, 1),
(3, 5, 800.00, 1),
(3, 12, 300.00, 1),
-- Document 4
(4, 5, 800.00, 1),
-- Document 5
(5, 8, 350.00, 6),
-- Document 6
(6, 1, 1500.00, 2),
(6, 12, 300.00, 2),
-- Document 7
(7, 6, 80.00, 5),
(7, 7, 150.00, 4),
(7, 9, 25.00, 8),
-- Document 8
(8, 1, 1500.00, 1),
(8, 2, 450.00, 1),
(8, 11, 150.00, 1),
-- Document 9
(9, 5, 800.00, 3),
(9, 10, 200.00, 9),
-- Document 10
(10, 1, 1500.00, 1),
(10, 3, 120.00, 1),
-- Document 11
(11, 1, 1500.00, 1),
(11, 2, 450.00, 1),
(11, 5, 800.00, 1),
-- Document 12
(12, 7, 150.00, 4),
(12, 10, 200.00, 2);

select *
from dbo.Customers

select *
from dbo.Docs

select *
from dbo.Docs_Data

select *
from dbo.Goods

--1.Вывести товары, объем остатка (сколько места на складе занимает этот товар) 
--которых на складе превышает значение, заданное параметром.
DECLARE @param FLOAT;   
SET @param = 1;

select good
from dbo.Goods
where QtyInStock*volume > @param

--2. Вывести города, в которых менее 5-ти покупателей.
select City
from dbo.Customers
WHERE City IS NOT NULL  
group by City
having count(Cust_ID) < 5

--3.Вывести все продажи (дата, ндок, товар, колво, цена) по покупателю, заданному параметром.
DECLARE @param INT;   
SET @param = 1;

select Data, D.DocNum, Good, Qty, DD.Price as [цена 1 товара]
from dbo.Docs as D inner join dbo.Docs_Data as DD on D.DocNum = DD.DocNum left join dbo.Goods as G on DD.Good_ID = G.Good_ID
where Cust_ID = @param

--4.Вывести уникальные наименования товаров, которые продавались в октябре 2025 года.
select distinct Good
from dbo.Docs as D inner join dbo.Docs_Data as DD on D.DocNum = DD.DocNum inner join dbo.Goods as G on DD.Good_ID = G.Good_ID
where month(cast(Data as date)) = 10 and year(cast(Data as date)) = 2025

--5.Вывести уникальные города, покупатели из которых покупали товар, заданный параметром.
DECLARE @param INT;   
SET @param = 1;

select distinct City
from dbo.Docs_Data DD inner join dbo.Docs D on DD.DocNum = D.DocNum inner join dbo.Customers C on D.Cust_ID = C.Cust_ID
where Good_ID = @param

--6.Вывести ФИО покупателя, купившего самый дорогой товар в октябре 2025. Самый дорогой товар – товар с самой большой продажной ценой.
select top 1 with ties Customer
from dbo.Docs_Data DD inner join dbo.Docs D on DD.DocNum = D.DocNum inner join dbo.Customers C on D.Cust_ID = C.Cust_ID
where month(data) = 10 and year(data) = 2025 
order by Price desc

--7.Вывести суммарно проданный объем (сумма(объем*колво)) товара в октябре 2025.
select sum(Volume*Qty) as [суммарно проданный объем]
from dbo.Docs_Data DD inner join dbo.Docs D on DD.DocNum = D.DocNum inner join dbo.Goods G on DD.Good_ID = G.Good_ID
where month(data) = 10 and year(data) = 2025 

--8.Выбрать город с максимальным оборотом (суммарной стоимостью) по отпуску товара. Если их несколько, то выводить все.

select top 1 with ties City
from dbo.Docs_Data DD inner join dbo.Docs D on DD.DocNum = D.DocNum inner join dbo.Customers C on D.Cust_ID = C.Cust_ID
group by City
order by sum(DD.Qty * DD.Price) desc

--9.По каждому покупателю вывести: суммарное колво, суммарную стоимость, суммарную массу и суммарный объем по купленному товару. 
--Во втором варианте посчитать это только по товарам, в названии которых есть подстрока «монитор». (можно сделать двумя запросами).

-- Вариант 1 (по всем товарам)
select Customer, sum(DD.Qty) as [Суммарное кол-во], sum(DD.Qty*DD.Price) as [Суммарная стоимость], sum(DD.Qty*G.Mass) as [Суммарная масса], sum(DD.Qty*G.Volume) as [Суммарный объем]
from dbo.Docs_Data DD inner join dbo.Docs D on DD.DocNum = D.DocNum inner join dbo.Customers C on D.Cust_ID = C.Cust_ID inner join dbo.Goods G on DD.Good_ID = G.Good_ID
group by Customer

-- Вариант 2 (только мониторы)
select Customer, sum(DD.Qty) as [Суммарное кол-во], sum(DD.Qty*DD.Price) as [Суммарная стоимость], sum(DD.Qty*G.Mass) as [Суммарная масса], sum(DD.Qty*G.Volume) as [Суммарный объем]
from dbo.Docs_Data DD inner join dbo.Docs D on DD.DocNum = D.DocNum inner join dbo.Customers C on D.Cust_ID = C.Cust_ID inner join dbo.Goods G on DD.Good_ID = G.Good_ID
where Good like N'%монитор%'
group by Customer


--10.Вывести документы, в которых суммарная стоимость товара в теле (документы_данные)
--не совпадает с суммарной стоимостью в заголовке (сумма в документах).

select D.DocNum
from dbo.Docs D inner join dbo.Docs_Data DD on D.DocNum = DD.DocNum
group by D.DocNum, D.Total
having D.Total <> sum(DD.Qty * DD.Price)
