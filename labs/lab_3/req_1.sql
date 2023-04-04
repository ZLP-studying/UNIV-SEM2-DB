-- 1 ------------------------------------------------------
-- Вывести информацию о количестве объектов недвижимости по
-- каждому этажу
-----------------------------------------------------------
SELECT
objects.floor, COUNT(*)
FROM
objects
GROUP BY objects.floor;

-- 2 ------------------------------------------------------
-- Вывести информацию о количестве объектов недвижимости по
-- каждому району
-----------------------------------------------------------
SELECT
districts.name, COUNT(*)
FROM
objects, districts
WHERE
objects.district_id = districts.id
GROUP BY districts.name;

-- 3 ----------------------------------------------------
-- Вывести информацию о количестве двухкомнатных объектах
-- недвижимости по каждому типу
---------------------------------------------------------
SELECT
types.name, COUNT(*)
FROM
objects, types
WHERE
objects.type_id = types.id
AND
objects.rooms = 2
GROUP BY types.name;

-- 4 -----------------------------------------------------------
-- Вывести информацию о средней стоимости объектов недвижимости,
-- расположенных на 2 этаже по каждому материалу здания
----------------------------------------------------------------
SELECT
materials.name, ROUND(AVG(objects.cost)::numeric, 2)
FROM
objects, materials
WHERE
objects.material_id = materials.id
AND
objects.floor = 2
GROUP BY materials.name;

-- 5 --------------------------------------------------
-- Вывести информацию о максимальной стоимости квартир,
-- расположенных в каждом районе
-------------------------------------------------------
SELECT
districts.name, MAX(objects.cost)
FROM
objects, districts, types
WHERE
objects.district_id = districts.id
AND
types.id = objects.type_id AND types.name = 'Квартира'
GROUP BY districts.name;

-- 6 -------------------------------------------------------
-- Вывести информацию о количестве квартир, проданных каждым
-- риэлтором
------------------------------------------------------------
SELECT
realtors.id, realtors.f_name, COUNT(*)
FROM
realtors, sales, types, objects
WHERE
sales.realtor_id = realtors.id
AND
types.id = objects.type_id AND types.name = 'Квартира'
AND
sales.object_id = objects.id
GROUP BY realtors.id;

-- 7 -------------------------------------------------
-- Вывести информацию об общей стоимости апартаментов,
-- расположенных в каждом районе
------------------------------------------------------
SELECT
districts.name, SUM(objects.cost)
FROM
objects, districts, types
WHERE
objects.district_id = districts.id
AND
types.id = objects.type_id AND types.name = 'Апартаменты'
GROUP BY districts.name;

-- 8 ------------------------------------------------------------
-- Вывести информацию о средней стоимости объектов недвижимости с
-- площадью «ОТ» и «ДО» по каждому типу объекта
-----------------------------------------------------------------
SELECT
types.name, AVG(objects.cost)
FROM
objects, types
WHERE
types.id = objects.type_id
AND
objects.square > 30 AND objects.square < 50
GROUP BY types.name;

-- 9 ----------------------------------------------------------
-- Вывести информацию о средней оценке объектов недвижимости по
-- каждому району
---------------------------------------------------------------
SELECT
districts.name, AVG(rates.rate)
FROM
objects, districts, rates
WHERE
objects.district_id = districts.id
AND
objects.id = rates.object_id
GROUP BY districts.name;

-- 10 ----------------------------------------------------------
-- Вывести информацию об общей продажной стоимости апартаментов,
-- проданных в диапазоне дат «ОТ» и «ДО» по каждому риэлтору
----------------------------------------------------------------
SELECT
realtors.s_name, realtors.f_name, realtors.t_name, SUM(sales.cost)
FROM
realtors, objects, sales, types
WHERE
sales.object_id = objects.id
AND
sales.date > '20.09.2010' AND sales.date < '20.09.2018'
AND
sales.realtor_id = realtors.id
AND
types.id = objects.type_id AND types.name = 'Апартаменты'
GROUP BY realtors.id;

-- 11 -------------------------------------------
-- Вывести информацию о средней оценке по каждому
-- критерию для объекта недвижимости
-------------------------------------------------
SELECT
objects.id, parameters.name, AVG(rates.rate)
FROM
objects, parameters, rates
WHERE
rates.object_id = objects.id
AND
rates.parameter_id = parameters.id
GROUP BY objects.id, parameters.name
ORDER BY objects.id;

-- 12 ---------------------------------
-- Вывести информацию о средней площади 
-- квартир по каждому району
---------------------------------------
SELECT
districts.name, ROUND(AVG(objects.square)::numeric, 2)
FROM
districts, objects
WHERE
objects.district_id = districts.id
GROUP BY districts.name;

-- 13 ---------------------------------------------------
-- Вывести информацию о максимальной и минимальной оценке
-- по каждому критерию для объекта недвижимости
---------------------------------------------------------
SELECT
objects.id, districts.name, objects.address, parameters.name, MAX(rates.rate), MIN(rates.rate)
FROM
objects, districts, rates, parameters
WHERE
rates.object_id = objects.id AND rates.parameter_id = parameters.id
AND
objects.district_id = districts.id
GROUP BY
objects.id, districts.name, objects.address, parameters.name
ORDER BY
objects.id, districts.name, objects.address, parameters.name;

-- 14 ------------------------------------------------------------------------
-- Вывести информацию о количестве объектах недвижимости по количеству комнат,
-- у которых разница между продажной и заявленной стоимостью больше 10000
------------------------------------------------------------------------------
SELECT
objects.rooms, COUNT(*)
FROM
objects, sales
WHERE
sales.object_id = objects.id
AND
ABS(objects.cost - sales.cost) > 10000
GROUP BY objects.rooms;
