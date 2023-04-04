--- 1 ------------------------------------------------------
-- Вывести адреса объектов недвижимости, у которых стоимость
-- 1 м2 меньше средней стоимости по району
------------------------------------------------------------
WITH dist_avg_cost AS (
	SELECT
	districts.id, AVG(objects.cost / objects.square) as sq_cost
	FROM
	districts, objects
	WHERE
	objects.district_id = districts.id
	GROUP BY
	districts.id
)

SELECT
objects.address
FROM
objects, dist_avg_cost
WHERE
objects.district_id = dist_avg_cost.id
AND
objects.cost / objects.square < dist_avg_cost.sq_cost;

--- 2 -------------------------------------------
-- Вывести название районов, в которых количество
-- проданных квартир больше 5
-------------------------------------------------
SELECT
districts.name, COUNT(*)
FROM
districts, objects, sales
WHERE
objects.district_id = districts.id
AND
sales.object_id = objects.id
GROUP BY
districts.name
HAVING
COUNT(*) > 5;

--- 3 --------------------------------------
-- Вывести адреса квартир и название района,
-- средняя оценка которых выше 3,5 баллов
--------------------------------------------
SELECT
districts.name, objects.address, AVG(rates.rate)
FROM
districts, objects, types, rates
WHERE
objects.district_id = districts.id
AND
objects.type_id = types.id AND types.name = 'Квартира'
AND
objects.id = rates.object_id
GROUP BY
districts.name, objects.address
HAVING
AVG(rates.rate) > 3.5;

--- 4 -----------------------------------
-- Вывести ФИО риэлторов, которые продали
-- меньше 5 объектов недвижимости
-----------------------------------------
SELECT
realtors.s_name, realtors.f_name, realtors.t_name, COUNT(*)
FROM
realtors, sales
WHERE
sales.realtor_id = realtors.id
GROUP BY
realtors.s_name, realtors.f_name, realtors.t_name
HAVING
COUNT(*) < 120;

--- 5 --------------------------------------
-- Определить годы, в которых было размещено
-- от 2 до 3 объектов недвижимости
--------------------------------------------
SELECT
EXTRACT(YEAR FROM objects.date) AS YEAR, COUNT(*)
FROM
objects
GROUP BY
YEAR
HAVING
COUNT(*) > 5 AND COUNT(*) < 10
ORDER BY
YEAR;

--- 6 -------------------------------------
-- Определить адреса квартир, стоимость 1м2
-- которых меньше средней по району
-------------------------------------------
WITH dist_avg_cost AS (
	SELECT
	districts.id, AVG(objects.cost / objects.square) as sq_cost
	FROM
	districts, objects, types
	WHERE
	objects.type_id = types.id AND types.name = 'Квартира'
	AND
	objects.district_id = districts.id
	GROUP BY
	districts.id
)

SELECT
objects.address
FROM
objects, dist_avg_cost, types
WHERE
objects.type_id = types.id AND types.name = 'Квартира'
AND
objects.district_id = dist_avg_cost.id
AND
objects.cost / objects.square < dist_avg_cost.sq_cost;

--- 7 ------------------------------
-- Определить ФИО риэлторов, которые
-- ничего не продали в текущем году
------------------------------------
SELECT
s_name, f_name, t_name
FROM realtors
WHERE id NOT IN (
    SELECT realtor_id
    FROM sales
    WHERE EXTRACT(YEAR FROM date) = EXTRACT(YEAR FROM NOW())
);

--- 8 ----------------------------------------
-- Вывести названия районов, в которых средняя
-- площадь продаваемых квартир больше 30м2
----------------------------------------------
WITH req AS (
	SELECT
	district_id, AVG(square) 
	FROM objects 
	GROUP BY district_id
)

SELECT districts.name 
FROM
districts, req
WHERE
districts.id = req.district_id 
AND
req.avg > 65;

--- 9 --------------------------------------------------
-- Вывести для указанного риэлтора (ФИО) года, в которых
-- он продал больше 2 объектов недвижимости
--------------------------------------------------------
SELECT
EXTRACT(YEAR FROM sales.date) as year
FROM sales JOIN (
	SELECT id
	FROM realtors
	WHERE
	s_name = 'Сафронов' AND f_name = 'Евгений' AND t_name = 'Максимович'
) AS r1
ON sales.realtor_id = r1.id
GROUP BY EXTRACT(YEAR FROM sales.date)
HAVING COUNT(*) > 2;

--- 10 -------------------------------------------------------------
-- Вывести ФИО риэлторов, которые заработали премию в текущем месяце
-- больше 40000 рублей. Премия рассчитываются по формуле:
-- общая стоимость всех проданных квартир * 15%
--------------------------------------------------------------------
WITH premias AS (
	SELECT
	realtors.id as realtor_id, SUM(sales.cost) * 0.15 AS value
	FROM
	realtors, sales
	WHERE
	sales.realtor_id = realtors.id
	AND
	EXTRACT(month FROM sales.date) = 5 AND EXTRACT(year FROM sales.date) = 2019
	GROUP BY
	realtors.id
)

SELECT
realtors.s_name, realtors.f_name, realtors.t_name, premias.value
FROM
realtors, premias
WHERE
premias.realtor_id = realtors.id
AND
premias.value > 40000;


--- 11 --------------------------------------------
-- Вывести количество однокомнатных и двухкомнатных
-- квартир в указанном районе
---------------------------------------------------
SELECT
CASE objects.rooms
WHEN 1 THEN 'Однокомнатная'
WHEN 2 THEN 'Двухкомнатная'
END,
COUNT(*)
FROM
objects, districts
WHERE
objects.district_id = districts.id AND districts.name = 'Митино'
AND
(objects.rooms = 1 OR objects.rooms = 2)
GROUP BY
objects.rooms;

--- 12 ------------------------------------------------
-- Определить индекс средней оценки по каждому критерию
-- для указанного объекта недвижимости
-------------------------------------------------------
SELECT
parameters.name,
CASE
WHEN AVG(rates.rate) >= 9 THEN '5 из 5'
WHEN AVG(rates.rate) >= 8 THEN '4 из 5'
WHEN AVG(rates.rate) >= 7 THEN '3 из 5'
WHEN AVG(rates.rate) >= 6 THEN '2 из 5'
ELSE '1 из 5' END,
CASE
WHEN AVG(rates.rate) >= 9 THEN 'превосходно'
WHEN AVG(rates.rate) >= 8 THEN 'очень хорошо'
WHEN AVG(rates.rate) >= 7 THEN 'хорошо'
WHEN AVG(rates.rate) >= 6 THEN 'удовлетворительно'
ELSE 'неудовлетворительно' END
FROM
objects, parameters, rates
WHERE
objects.id = 2
AND
objects.id = rates.object_id
AND
rates.parameter_id = parameters.id
GROUP BY parameters.name;

--- 13 ----------------------------------------------------------------
-- Добавить новую таблицу «Структура объекта недвижимости» с колонками:
-- Объект недвижимости, Тип комнаты, Площадь.
-- Установите ограничение-проверку площади, которая должна быть
-- больше нуля и типа комнаты (1, 2, 3, 4), где
-- 1 – кухня, 2 – зал, 3 – спальня, 4 – санузел
-----------------------------------------------------------------------
CREATE OR REPLACE FUNCTION structures_tigger()
RETURNS TRIGGER AS
$$
BEGIN
IF NEW.square < 0 THEN
RAISE EXCEPTION 'ERROR! Square < 0';
END IF;
IF NEW.room_type_id > 4 THEN
RAISE EXCEPTION 'ERROR! room_type_id > 4';
END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER structures_tigger
BEFORE INSERT OR UPDATE
ON structures
FOR EACH ROW
EXECUTE FUNCTION structures_tigger();

-- «Структуры квартир» - structures
DROP TABLE IF EXISTS structures CASCADE;
CREATE TABLE IF NOT EXISTS structures (
	object_id bigint references objects(id),
	room_type_id bigint,
	square double precision
);

--- 14 --------------------------------------------------
-- Вывести информацию о комнатах для объекта недвижимости
---------------------------------------------------------
SELECT
CASE structures.room_type_id
WHEN 1 THEN 'Кухня'
WHEN 2 THEN	'Гостиная'
WHEN 3 THEN	'Туалет'
WHEN 4 THEN	'Спальня'
END,
structures.square
FROM
structures, objects
WHERE
structures.object_id = objects.id
AND
objects.id = 1;

--- 15 -----------------------------------------------------------------------------
-- Вывести количество объектов недвижимости по каждому району, общая площадь которых
-- больше 40 м2. Использовать таблицу «Структура объекта недвижимости»
------------------------------------------------------------------------------------
WITH obj_sq AS (
	SELECT
	object_id, SUM(square) AS rooms_sq
	FROM
	structures
	GROUP BY
	object_id
)

SELECT
districts.name, COUNT(*)
FROM
districts, objects, obj_sq
WHERE
objects.district_id = districts.id
AND
objects.id = obj_sq.object_id AND obj_sq.rooms_sq > 40
GROUP BY
districts.name;

--- 16 -------------------------------------------------------
-- Используя функции для работы с датой:
-- extract(field from timestamp) и age(timestamp, timestamp),
-- вывести квартиры,которые были проданы
-- не позже 4 месяцев после размещения объявления о их продаже
--------------------------------------------------------------
SELECT
objects.address
FROM
objects, types, sales
WHERE
objects.type_id = types.id AND types.name = 'Квартира'
AND
sales.object_id = objects.id
AND
EXTRACT(MONTH FROM AGE(sales.date, objects.date)) > 0
AND
EXTRACT(MONTH FROM AGE(sales.date, objects.date)) <= 4
AND
EXTRACT(YEAR FROM AGE(sales.date, objects.date)) = 0;

--- 17 --------------------------------------------------------
-- Вывести адреса объектов недвижимости, стоимость 1м2 которых
-- меньше среднейвсех объектов недвижимости по району,
-- объявления о которых были размещены не более 4 месяцев назад
---------------------------------------------------------------
WITH dist_avg_cost AS (
	SELECT
	districts.id, AVG(objects.cost / objects.square) as sq_cost
	FROM
	districts, objects, types
	WHERE
	objects.type_id = types.id AND types.name = 'Квартира'
	AND
	objects.district_id = districts.id
	GROUP BY
	districts.id
)

SELECT
objects.address,
CASE objects.status
WHEN TRUE THEN 'в продаже'
WHEN FALSE THEN 'продано'
END
FROM
objects, sales, dist_avg_cost
WHERE
sales.object_id = objects.id
AND
EXTRACT(MONTH FROM AGE(NOW(), sales.date)) > 0 AND EXTRACT(MONTH FROM AGE(NOW(), sales.date)) <= 4
AND
EXTRACT(YEAR FROM AGE(NOW(), sales.date)) = 0
AND
dist_avg_cost.id = objects.district_id
AND
(objects.cost / objects.square) < dist_avg_cost.sq_cost;

--- 18 ---------------------------------------------------------
-- Вывести информацию о количество продаж в предыдущем и текущем
-- годах по каждому району, а также процент изменения
----------------------------------------------------------------
WITH "2021" AS (
  SELECT
  district_id, COUNT(*)
	FROM (
    (
      SELECT object_id
      FROM sales
      WHERE EXTRACT(year FROM sales.date) = 2021
    ) as "a"
    JOIN
    (
      SELECT
      objects.id, objects.district_id
      FROM objects
    ) AS "b"
    ON "a".object_id = "b".id
  )
  GROUP BY district_id
),
"2022" AS (
  SELECT district_id, count(*)
  FROM (
    (
      SELECT object_id
      FROM sales
      WHERE EXTRACT(year FROM sales.date) = 2022
    ) AS "a"
    JOIN
    (
      SELECT
      objects.id, objects.district_id
      FROM objects
    ) as "b"
    ON "a".object_id = "b".id
  )
  GROUP BY district_id
)

SELECT
districts.name, "2021".count, "2022".count,
round((("2022".count - "2021".count) / "2022".count::decimal) * 100) AS delta
FROM
"2021", "2022", districts
WHERE
districts.id = "2021".district_id
AND
districts.id = "2022".district_id;
