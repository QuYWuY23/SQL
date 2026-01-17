-- Структура таблицы
CREATE TABLE Polynomials (
    P_ID INT,
    Pow INT,
    Coeff REAL
);

-- Пример данных для 3 разных полиномов:
-- 1. x^2 + 1
-- 2. -2x^3 + 4x + 7
-- 3. 0.5x^4 - x^2 + 3

INSERT INTO Polynomials (P_ID, Pow, Coeff) VALUES
-- x^2 + 1
(1, 2, 1),
(1, 0, 1),

-- -2x^3 + 4x + 7
(2, 3, -2),
(2, 1, 4),
(2, 0, 7),

-- 0.5x^4 - x^2 + 3
(3, 4, 0.5),
(3, 2, -1),
(3, 0, 3);

INSERT INTO Polynomials (P_ID, Pow, Coeff) VALUES

-- p_1(x) = x^2 + 1
(1, 2, 1), (1, 0, 1),

-- p_2(x) = -3x^5 + 2x^2 - 8
(2, 5, -3), (2, 2, 2), (2, 0, -8),

-- p_3(x) = 0.5x^4 - x^2 + 7x
(3, 4, 0.5), (3, 2, -1), (3, 1, 7),

-- p_4(x) = x^4 + x^3 + x^2 + x + 1
(4, 4, 1), (4, 3, 1), (4, 2, 1), (4, 1, 1), (4, 0, 1),

-- p_5(x) = 4x^3 - 3x^2 + 2x - 1
(5, 3, 4), (5, 2, -3), (5, 1, 2), (5, 0, -1),

-- p_6(x) = -1.5x^5 + x^4 - 2x^3 + 6
(6, 5, -1.5), (6, 4, 1), (6, 3, -2), (6, 0, 6),

-- p_7(x) = 2x^7 + 5x^4 - x
(7, 7, 2), (7, 4, 5), (7, 1, -1),

-- p_8(x) = x^6 + x^3 + 12
(8, 6, 1), (8, 3, 1), (8, 0, 12),

-- p_9(x) = -7x^2 + 3
(9, 2, -7), (9, 0, 3),

-- p_10(x) = 0.25x^5 + 0.5x^4 - 0.75
(10, 5, 0.25), (10, 4, 0.5), (10, 0, -0.75),

-- p_11(x) = 5x^2 - 10x + 3
(11, 2, 5), (11, 1, -10), (11, 0, 3),

-- p_12(x) = x^3 - x^2 + x - 1
(12, 3, 1), (12, 2, -1), (12, 1, 1), (12, 0, -1),

-- p_13(x) = -2x^4 + 2x^2 + 6
(13, 4, -2), (13, 2, 2), (13, 0, 6),

-- p_14(x) = 7x^7 + 3x^3 - 2x
(14, 7, 7), (14, 3, 3), (14, 1, -2),

-- p_15(x) = 9x^6 + 8x^5 + 7x^4 + 6x^3 + 5x^2 + 4x + 3
(15, 6, 9), (15, 5, 8), (15, 4, 7), (15, 3, 6), (15, 2, 5), (15, 1, 4), (15, 0, 3),

-- p_16(x) = x^3 + x + 1
(16, 3, 1), (16, 1, 1), (16, 0, 1),

-- p_17(x) = -0.5x^2 + 2x - 1.5
(17, 2, -0.5), (17, 1, 2), (17, 0, -1.5),

-- p_18(x) = x^4 - 2x^2 + 1
(18, 4, 1), (18, 2, -2), (18, 0, 1),

-- p_19(x) = 3x^3 + 2x^2 + x + 5
(19, 3, 3), (19, 2, 2), (19, 1, 1), (19, 0, 5),

-- p_20(x) = 10x^2 - x + 7
(20, 2, 10), (20, 1, -1), (20, 0, 7);

INSERT INTO Polynomials (P_ID, Pow, Coeff) VALUES
(20, 2, 10), (20, 1, -1), (20, 0, 0);

INSERT INTO Polynomials (P_ID, Pow, Coeff) VALUES
(21, 2, 0), (21, 1, 0), (21, 0, 0);

INSERT INTO Polynomials (P_ID, Pow, Coeff) VALUES
(22, 2, 1), (22, 1, 2), (22, 0, 1);

INSERT INTO Polynomials (P_ID, Pow, Coeff) VALUES
(23, 2, 0), (23, 1, 2), (23, 0, 1);

INSERT INTO Polynomials (P_ID, Pow, Coeff) VALUES
(24, 2, 1), (24, 1, 2), (24, 0, -1);

select *
from Polynomials

--2.Написать запрос с параметром, который показывает полином, хранящийся в базе данных. 
--В качестве параметра запрос должен принимать идентификатор полинома в базе данных.
DECLARE @param INT;   
SET @param = 5;

select STRING_AGG(' ' +
case 
when coeff > 0 then '+' + CAST(Coeff AS VARCHAR(20)) 
else  +  CAST(Coeff AS VARCHAR(20)) end
+
case when Pow = 0 then ''
else '*x^'+ CAST(Pow AS VARCHAR(10)) end,
' ') as Polinom
from Polynomials
where P_ID = @param and coeff != 0

--3.Назовем хранение полинома корректным, если все хранящиеся в базе коэффициенты полинома отличны от нуля.
--Написать запрос, выводящий идентификаторы некорректно хранящихся полиномов.

select distinct(P_ID)
from Polynomials
where coeff = 0 

--4.Написать запрос с параметрами, который возвращает полином, умноженный на действительное число. 
--В качестве параметров запрос должен принимать идентификатор полинома в базе данных (первым параметром); 
--действительное число, на которое нужно умножить полином.
DECLARE @polinom INT;
DECLARE @scalar FLOAT;

SET @polinom = 5;
SET @scalar = -3;

select P_ID, Pow,  coeff*@scalar as new_coeff
from Polynomials
where P_ID = @polinom

--5.Написать запрос с параметрами, который принимает в качестве параметра идентификатор полинома в базе данных и натуральное число n
--и возвращает результат ("да"/"нет"), является ли указанный полином полиномом степени n. 
--(Учитывать в запросе то, что полиномы могут храниться некорректно, Вы должны проверять степень при ненулевом коэффициенте).
DECLARE @poli INT;
DECLARE @n  INT;

SET @poli = 5;
SET @n = 4;

select  case when max(Pow) = @n then 'yes' else 'no' end as [является ли полином полиномом степени n]
from Polynomials
where P_ID = @poli and coeff != 0

--6.Написать запрос с параметрами, который возвращает результат сложения двух полиномов. 
--В качестве параметров запрос должен принимать идентификаторы полиномов в базе данных. Нулевые коэффициенты не выводить.
DECLARE @poli INT;
DECLARE @polinom INT;

SET @poli = 5;
SET @polinom = 4;

with Summed_coeff as(
select  Pow, sum(coeff) as coeff
from Polynomials
where P_ID = @poli or P_ID = @polinom
group by Pow
having sum(coeff) != 0
)

select STRING_AGG(' ' +
case 
when coeff > 0 then '+' + CAST(Coeff AS VARCHAR(20)) 
else  +  CAST(Coeff AS VARCHAR(20)) end
+
case when Pow = 0 then ''
else '*x^'+ CAST(Pow AS VARCHAR(10)) end,
' ') WITHIN GROUP (ORDER BY Pow DESC) as Polinom
from Summed_coeff

--7.Написать запрос с параметрами, который возвращает результат умножения двух полиномов. 
--В качестве параметров запрос должен принимать идентификаторы полиномов в базе данных. Нулевые коэффициенты не выводить.

DECLARE @poli INT;
DECLARE @polinom INT;

SET @poli = 5;
SET @polinom = 4;

with New_Polinom as (
select p1.Pow + p2.Pow as New_Pow, p1.Coeff * p2.Coeff as new_Coeff
from Polynomials p1, Polynomials p2 
where p1.P_ID = @poli and p2.P_ID = @polinom and p1.Coeff != 0 and p2.Coeff != 0
)

select New_Pow as [final pow], sum(new_Coeff) as [final coeff]
from New_Polinom
group by New_Pow
having sum(new_Coeff) != 0

--8.Написать запрос с параметрами, вычисляющий значение полинома, 
--идентификатор которого параметр, где значение x – действительная величина, задаваемая параметром.

DECLARE @polinom INT;
DECLARE @x float;

SET @x = 5;
SET @polinom = 5;

select sum(power(@x, Pow) * Coeff) as value
from Polynomials
where P_ID = @polinom

--9.Написать запрос с параметром, проверяющий, является ли полином, 
--идентификатор которого задается параметром, полным квадратом от линейного полинома. Вывести результат в виде («да»/«нет»).

DECLARE @polinom INT;
SET @polinom = 22;

select case 
when max(Pow) is NULL or max(Pow) != 2 then 'no'
when max(power(CASE WHEN Pow = 1 THEN Coeff END, 2)) - 4*max(case when Pow = 2 then coeff end)*max(case when Pow = 0 then coeff end) = 0
then 'yes' else 'no' end as [полный ли квадрат от линейного полинома]
from Polynomials
where P_ID = @polinom

--10.Написать запрос с параметром, который вычисляет по полиному, идентификатор которого указывается параметром, 
--количество его коэффициентов равных нулю, больших нуля, меньших нуля. (Учитывать, что полиномы могут храниться некорректно, 
--например, если полином выглядит так: , то кол-во положительных равно 2, отрицательных 1, а нулевых 1, 
--нули при 4-й и 5-й степени не учитываем, так как полином степени 3).

DECLARE @polinom INT;
SET @polinom = 21;

select count(case when Coeff > 0 then Coeff end) as [Положительные коэфф], 
count(case when Coeff < 0 then Coeff end) as [Отрицательные коэфф], 
case when max(Pow) is NULL then -1 else max(Pow) end 
+ 1 - count(case when Coeff > 0 then Coeff end) - count(case when Coeff < 0 then Coeff end) as [Нулевые коэфф]
from Polynomials
where P_ID = @polinom  and Coeff != 0

--11.Написать запрос с параметром, который по полиному, идентификатор которого указывается параметром, выводит «да»,
--если все коэффициенты полинома – целые числа, иначе выводит «нет».

DECLARE @polinom INT;
SET @polinom = 21;

select case when count(case when ABS(Coeff - ROUND(Coeff, 0)) > 1e-10 then 1 end) = 0 then 'yes' else 'no' end as [целые ли коэфф]
from Polynomials
where P_ID = @polinom

--12.Написать запрос, который по полиному, идентификатор которого задается параметром, проверяет, 
--является ли полином полиномом первой степени, если да, то на выходе выводит значение x, являющееся корнем полинома.

DECLARE @polinom INT;
SET @polinom = 23;

select case when max(Pow) != 1 or max(Pow) is NULL then 'no polinom 1-st degree'
else cast( -sum(cast(case when Pow = 0 then coeff else 0 end as float)) / sum(case when Pow = 1 then coeff end) AS NVARCHAR(20)) 
end as [корень полинома]
from Polynomials
where P_ID = @polinom and  Coeff != 0

--13.Написать запрос, который по полиному, идентификатор которого задается параметром, проверяет, 
--является ли полином полиномом второй степени, если да, то на выходе выводит значения x, являющиеся корнями полинома.

DECLARE @polinom INT;
SET @polinom = 21;

with coefficients as (
select sum(case when Pow = 2 then coeff end) as a, sum(case when Pow = 1 then coeff else 0 end) as b, 
sum(case when Pow = 0 then coeff else 0 end) as c, max(Pow) as MaxPow
from Polynomials
where P_ID = @polinom and  Coeff != 0
),
Discriminant as(
select power(b,2) - 4*a*c as D, a,b,c, MaxPow
from coefficients
)

select case when MaxPow != 2 or MaxPow is NULL then 'no polinom 2-nd degree' 
when D < 0 then 'no  real roots'
else cast(cast((-b+power(D, 0.5)) as float)/(2*a) as NVARCHAR(100)) + ' ' +
cast(cast((-b-power(D, 0.5)) as float)/(2*a) as NVARCHAR(100)) 
end as roots
from Discriminant


--14.Написать запрос, который по трем идентификаторам полиномов, задаваемых параметрами, выводит 1, 
--в случае если третий полином является результатом умножения двух других.

DECLARE @polinom1 INT;
DECLARE @polinom2 INT;
DECLARE @polinom3 INT;

SET @polinom1 = 20;
SET @polinom2 = 19;
SET @polinom3 = 18;


with New_Polinom as (
select p1.Pow + p2.Pow as New_Pow, p1.Coeff * p2.Coeff as new_Coeff
from Polynomials p1, Polynomials p2 
where p1.P_ID = @polinom1 and p2.P_ID = @polinom2 and p1.Coeff != 0 and p2.Coeff != 0
),
Final_Polinom as (
select New_Pow as [final pow], sum(new_Coeff) as [final coeff]
from New_Polinom 
group by New_Pow
having sum(new_Coeff) != 0
)
select case when sum(case when f.[final coeff] - p.Coeff < 1e-6 then 0
else 1 end) = 0 then 1
else 0 end as [1-st * 2-nd = 3-rd polinom]
from Final_Polinom  as f 
full join (select * from Polynomials where P_ID = @polinom3) as p on f.[final pow] = p.Pow;

--15.Написать запрос, который по трем идентификаторам полиномов, задаваемых параметрами, выводит 1,
--в случае если третий полином является результатом деления первого на второй.

DECLARE @polinom1 INT;
DECLARE @polinom2 INT;
DECLARE @polinom3 INT;

SET @polinom1 = 20;
SET @polinom2 = 19;
SET @polinom3 = 18;


with New_Polinom as (
select p3.Pow + p2.Pow as New_Pow, p3.Coeff * p2.Coeff as new_Coeff
from Polynomials p3, Polynomials p2 
where p3.P_ID = @polinom3 and p2.P_ID = @polinom2 and p3.Coeff != 0 and p2.Coeff != 0
),
Final_Polinom as (
select New_Pow as [final pow], sum(new_Coeff) as [final coeff]
from New_Polinom 
group by New_Pow
having sum(new_Coeff) != 0
)
select case when sum(case when f.[final coeff] - p.Coeff < 1e-6 then 0
else 1 end) = 0 then 1
else 0 end as [1-st / 2-nd = 3-rd polinom]
from Final_Polinom  as f 
full join (select * from Polynomials where P_ID = @polinom1) as p on f.[final pow] = p.Pow;
--По факту, воспользовался эквивалентностью, что если 1/2 = 3 то 3 * 2 = 1 (под цифрами понимаются полиномы)