
--1.Напишите запросы, на создание таблиц с описанной выше структурой (жирным выделены ключи, можете создать на Ваше усмотрение
--ограничения и внешние ключи).

-- Таблица Customers
create table dbo.Customers (
    Customer_ID int primary key identity(1,1),
    Customer nvarchar(100) not null
);

-- Таблица Goods
create table dbo.Goods (
    Good_ID int primary key identity(1,1),
    Good nvarchar(100) not null,
    CurrPrice decimal(10, 2) not null
);

-- Таблица Docs
create table dbo.Docs (
    Ndoc int primary key,
    DocDate datetime not null,
    Customer_ID int not null,
    Total decimal(10, 2) not null,
    constraint FK_Docs_Customers foreign key (Customer_ID) references dbo.Customers(Customer_ID)
);

-- Таблица Docs_data
create table dbo.Docs_Data (
    Ndoc int not null,
    Good_ID int not null,
    Price decimal(10, 2) not null,
    Qty int not null,
    constraint PK_Docs_Data primary key (Ndoc, Good_ID),
    constraint FK_Docs_Data_Docs foreign key (Ndoc) references dbo.Docs(Ndoc),
    constraint FK_Docs_Data_Goods foreign key (Good_ID) references dbo.Goods(Good_ID)
);


--2.Вставьте при помощи запроса на вставку в таблицу Customers трех покупателей, а в таблицу Goods три товара 
--(эти данные на Ваше усмотрение).

-- Вставка покупателей
insert into dbo.Customers (Customer)
values 
    (N'Иван Петров'),
    (N'Мария Сидорова'),
    (N'Петр Иванов');

-- Вставка товаров
insert into dbo.Goods (Good, CurrPrice)
values 
    (N'Монитор 27 дюйм', 15000.00),
    (N'Клавиатура механическая', 5000.00),
    (N'Мышь беспроводная', 2000.00);



--3.Для каждого покупателя заполните таблицу «Docs_data» следующим образом: для простоты Ndoc равен коду покупателя. 
--Cчитаем, что каждый покупатель купил каждый товар (то есть по 3 строки в таблице «Docs_data» для каждого покупателя). 
--Qty = Целое (рандомное число от 1 до 5). Рандомное число от 0 до 1 можно сгенерировать, например, так: RAND(CHECKSUM(NEWID())).
--Запрос на вставку должен явно использовать данные из таблиц Goods и Customers.

insert into dbo.Docs (Ndoc, DocDate, Customer_ID, Total)
select 
    C.Customer_ID as Ndoc,
    cast(getdate() as date) as DocDate,
    C.Customer_ID,
    0 as Total 
from dbo.Customers C;


insert into dbo.Docs_Data (Ndoc, Good_ID, Price, Qty)
select 
    C.Customer_ID as Ndoc,
    G.Good_ID,
    G.CurrPrice as Price,
    cast(abs(checksum(rand(checksum(newid()))) % 5) + 1 as int) as Qty
from dbo.Customers C
cross join dbo.Goods G
order by C.Customer_ID, G.Good_ID;


--4.На основе данных в таблице Docs_data вставить данные в таблицу Docs. DocDate – текущая дата. 
--Total – суммарная стоимость всех товаров в этом чеке.

update dbo.Docs
set Total = (
    select sum(DD.Qty * DD.Price)
    from dbo.Docs_Data DD
    where DD.Ndoc = dbo.Docs.Ndoc
);



--5.В таблице «Docs_data» увеличьте в 1,5 раза цену товара с минимальным идентификатором.

update dbo.Docs_Data
set Price = Price * 1.5
where Good_ID = (select min(Good_ID) from dbo.Goods);


--6.Обновите поле Total в таблице «Docs», так как теперь сумма не соответствует действительности.

update dbo.Docs
set Total = (
    select sum(DD.Qty * DD.Price)
    from dbo.Docs_Data DD
    where DD.Ndoc = dbo.Docs.Ndoc
);

--7.Выведите покупателей, у которых хотя бы раз стоимость покупки (сумма в чеке) была больше, чем средняя стоимость закупки по всем 
--покупателям за ноябрь 2024(я сделал для декабря 2025). Просьба при написании запроса считать, что данных в таблице намного больше, чем Вы уже вставили.

select distinct C.Customer_ID, C.Customer
from dbo.Customers C
inner join dbo.Docs D on C.Customer_ID = D.Customer_ID
where D.Total > (
    select avg(D2.Total)
    from dbo.Docs D2
)
order by C.Customer_ID;

