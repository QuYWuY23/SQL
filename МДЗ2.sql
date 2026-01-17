--1.Выведите суммарное колво пассажиров и колво выживших. Вычислите долю выживших (в виде десятичной дроби от 0 до 1).
select count(survived) as Пассажиры, sum(survived) as Выжившие, (cast(sum(survived) as float)/count(survived)) as [Доля выживших] 
from dbo.Titanic
--2.Посчитайте по каждому классу билета суммарное колво пассажиров и колво выживших. 
--Вычислите долю выживших по каждому классу билета (в виде десятичной дроби от 0 до 1).
select Pclass,count(survived) as Пассажиры, sum(survived) as Выжившие, (cast(sum(survived) as float)/count(survived)) as [Доля выживших] 
from dbo.Titanic
group by Pclass
order by Pclass;
--3.По каждому классу билета и полу пассажира посчитайте: суммарное колво пассажиров, колво выживших и долю выживших.
select Pclass, Sex, count(survived) as Пассажиры, sum(survived) as Выжившие, (cast(sum(survived) as float)/count(survived)) as [Доля выживших] 
from dbo.Titanic
group by Pclass, Sex
order by Pclass, Sex
--4.По каждому порту отправления посчитайте колво пассажиров, колво выживших и долю выживших.
select Embarked,count(survived) as Пассажиры, sum(survived) as Выжившие, (cast(sum(survived) as float)/count(survived)) as [Доля выживших] 
from dbo.Titanic
group by Embarked
--5.Выведите порт отправления с наибольшим колвом пассажиров.
select top 1 Embarked
from dbo.Titanic
group by Embarked
order by count(survived) desc
--6.Посчитайте средний возраст пассажиров и средний возраст выживших в группировке по классу билета и полу.
--При подсчете среднего возраста посмотрите, а как у Вас проимпортировались данные, где возраст указан не был. 
--Если как NULL, то средний возраст посчитается верно при использовании AVG (позже изучим обработку NULL значений), иначе, 
--если неизвестные возраста заменились на 0, подумайте, как правильно посчитать средний возраст только по ненулевым age? (хинт: CASE WHEN)
select Pclass, Sex,  avg(case when age > 0 then age else Null end) as [средний возраст пассажиров],
avg(case when age > 0 and survived = 1 then age else Null end) as [средний возраст выживших]
from dbo.Titanic
group by Pclass, Sex
order by Pclass, Sex
--7.Выведите первые 10 строк по убыванию стоимости билета. Как Вы считаете, стоимость билета указана на человека?
select top 10 Fare
from МДЗ2.dbo.Titanic
order by Fare desc
--8.Проверьте, есть ли билеты, для которых цена в разных строках отличается? 
--Выведите их. Аналогично для порта отправления (можно в два запроса).
select Ticket
from МДЗ2.dbo.Titanic
group by Ticket
having count(distinct Fare) > 1
--второй способ, + можно посмотреть как сильно стоимость отличается
select Ticket, min(Fare) as минимум, max(Fare) as максимум
from МДЗ2.dbo.Titanic
group by Ticket
having min(Fare) != max(Fare)

select Ticket
from МДЗ2.dbo.Titanic
group by Ticket
having count(distinct embarked) > 1

--9.Для каждого номера билета, класса, цены и порта отправления посчитайте колво строк (колво пассажиров), колво выживших пассажиров.
select count(PassengerId) as [кол-во],count(case when survived = 1 then PassengerId end) as [кол-во выживших],
ticket, Pclass, Fare, embarked
from МДЗ2.dbo.Titanic
group by ticket, Pclass, Fare, embarked
--тут можно было сделать через count(survived) и sum(survived) как в прошлые разы, но я решил разнообразить

--10.Выведите билеты, для которых колво пассажиров более 1 и все пассажиры выжили.
select Ticket
from МДЗ2.dbo.Titanic
group by Ticket
having count(distinct(PassengerId)) > 1 and count(survived) = sum(survived)

--11.Напишите запрос, который посчитает вероятность выжить, если Вас зовут Elizabeth, 
--если Вас зовут Mary (достаточно посчитать, что такая подстрока должна входить в имя пассажира)
select 
    case 
        when Name like '%Elizabeth%' then 'Elizabeth'
        when Name like '%Mary%' then 'Mary'
    end as NameGroup,
    cast(sum(survived) as float)/count(survived) as [вероятность выживания]
from МДЗ2.dbo.Titanic
where Name like '%Elizabeth%' or Name like '%Mary%'
group by 
    case 
        when Name like '%Elizabeth%' then 'Elizabeth'
        when Name like '%Mary%' then 'Mary'
    end
