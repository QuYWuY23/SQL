-- 1. Для каждого покупателя посчитать количество документов
--    если покупатель ни разу не закупался, то выводить 0

select p.Pokupatel_ID,
       concat(p.Familia, ' ', p.Imya) as FIO,
       count(d.Ndok) as KolvoDoKumentov
from dbo.Pokupateli p
left join dbo.Dokumenty d on p.Pokupatel_ID = d.Pokupatel_ID
group by p.Pokupatel_ID, p.Familia, p.Imya
order by p.Pokupatel_ID;

-- 2. Вывести все товары, которые ни разу не продавались

select t.Tovar_ID,
       t.Naimenovanie,
       t.Ostatrk as OstatokNaSkladu,
       t.Tsena
from dbo.Tovary t
left join dbo.Dokumenty_Dannye dd on t.Tovar_ID = dd.Tovar_ID
where dd.Tovar_ID is null
order by t.Tovar_ID;

-- 3. Вывести все товары, которые ни разу не продавались покупателю
--    с фамилией Иванов (Ivanov)

select distinct t.Tovar_ID,
       t.Naimenovanie,
       t.Ostatrk as OstatokNaSkladu,
       t.Tsena
from dbo.Tovary t
where t.Tovar_ID not in (
    select dd.Tovar_ID
    from dbo.Dokumenty_Dannye dd
    inner join dbo.Dokumenty d on dd.Ndok = d.Ndok
    inner join dbo.Pokupateli p on d.Pokupatel_ID = p.Pokupatel_ID
    where p.Familia = 'Ivanov'
)
order by t.Tovar_ID;

-- 4. Вывести все пары покупатель_id, товар_id такие, что покупатель_id
--    никогда не покупал товар с идентификатором товар_ID

select p.Pokupatel_ID,
       t.Tovar_ID
from dbo.Pokupateli p
cross join dbo.Tovary t
where not exists (
    select 1
    from dbo.Dokumenty_Dannye dd
    inner join dbo.Dokumenty d on dd.Ndok = d.Ndok
    where d.Pokupatel_ID = p.Pokupatel_ID
    and dd.Tovar_ID = t.Tovar_ID
)
order by p.Pokupatel_ID, t.Tovar_ID;

-- 5. Вывести все пары покупатель_id, товар_id такие, что покупатель_id
--    не покупал товар с идентификатором товар_ID после 01.10.25

select p.Pokupatel_ID,
       t.Tovar_ID
from dbo.Pokupateli p
cross join dbo.Tovary t
where not exists (
    select 1
    from dbo.Dokumenty_Dannye dd
    inner join dbo.Dokumenty d on dd.Ndok = d.Ndok
    where d.Pokupatel_ID = p.Pokupatel_ID
    and dd.Tovar_ID = t.Tovar_ID
    and d.Data > '2025-10-01'
)
order by p.Pokupatel_ID, t.Tovar_ID;

-- 6. Вывести покупателей, которые купили менее 5-ти уникальных артикулов

select p.Pokupatel_ID,
       concat(p.Familia, ' ', p.Imya) as FIO,
       count(distinct dd.Tovar_ID) as KolvoUnikalnykhTovarov
from dbo.Pokupateli p
left join dbo.Dokumenty d on p.Pokupatel_ID = d.Pokupatel_ID
left join dbo.Dokumenty_Dannye dd on d.Ndok = dd.Ndok
group by p.Pokupatel_ID, p.Familia, p.Imya
having count(distinct dd.Tovar_ID) < 5
order by p.Pokupatel_ID;

-- 7. Выбрать пары покупателей, которые закупили одинаковое множество товаров
--    (сравнивать только артикулы без учета купленного кол-ва)
--    Вывод: идентификатор1, идентификатор2 (ид1 < ид2)

with BuyerBaskets as (
    select distinct p.Pokupatel_ID,
           dd.Tovar_ID
    from dbo.Pokupateli p
    inner join dbo.Dokumenty d on p.Pokupatel_ID = d.Pokupatel_ID
    inner join dbo.Dokumenty_Dannye dd on d.Ndok = dd.Ndok
),
BasketHashes as (
    select p1.Pokupatel_ID,
           string_agg(cast(p1.Tovar_ID as nvarchar(10)), ',') within group (order by p1.Tovar_ID) as BasketHash
    from BuyerBaskets p1
    group by p1.Pokupatel_ID
)
select bh1.Pokupatel_ID as Pokupatel_ID_1,
       bh2.Pokupatel_ID as Pokupatel_ID_2
from BasketHashes bh1
inner join BasketHashes bh2 on bh1.BasketHash = bh2.BasketHash
where bh1.Pokupatel_ID < bh2.Pokupatel_ID
order by bh1.Pokupatel_ID, bh2.Pokupatel_ID;

-- 8. Для каждого покупателя посчитать его рейтинг
--    рейтинг = 1 – у клиента с максимальными закупками и т.д.
--    Если суммы одинаковы, рейтинг одинаков и равен максимальному

select p.Pokupatel_ID,
       concat(p.Familia, ' ', p.Imya) as FIO,
       isnull(sum(d.Summa), 0) as SummaCrokupok,
       dense_rank() over (order by isnull(sum(d.Summa), 0) desc) as Reiting
from dbo.Pokupateli p
left join dbo.Dokumenty d on p.Pokupatel_ID = d.Pokupatel_ID
group by p.Pokupatel_ID, p.Familia, p.Imya
order by Reiting, p.Pokupatel_ID;

-- 9. Вывести товары, которые либо сейчас есть на складе,
--    либо были куплены в ноябре 2025, либо и то, и другое

select distinct t.Tovar_ID,
       t.Naimenovanie,
       t.Ostatrk as OstatokNaSkladu,
       t.Tsena
from dbo.Tovary t
left join dbo.Dokumenty_Dannye dd on t.Tovar_ID = dd.Tovar_ID
left join dbo.Dokumenty d on dd.Ndok = d.Ndok
where t.Ostatrk > 0
or (year(d.Data) = 2025 and month(d.Data) = 11)
order by t.Tovar_ID;


-- 10. Для каждого артикула посчитать среднюю сумму продаж в день
--     Среднее по всем дням, когда проводились какие-либо продажи

select t.Tovar_ID,
       t.Naimenovanie,
       sum(dd.Kolvo * dd.Tsena) as ObtschayaSumma,
       count(distinct d.Data) as KolvoDneySProdazhey,
       sum(dd.Kolvo * dd.Tsena) / count(distinct d.Data) as SrednyayaSummVDen
from dbo.Tovary t
inner join dbo.Dokumenty_Dannye dd on t.Tovar_ID = dd.Tovar_ID
inner join dbo.Dokumenty d on dd.Ndok = d.Ndok
group by t.Tovar_ID, t.Naimenovanie
order by t.Tovar_ID;
