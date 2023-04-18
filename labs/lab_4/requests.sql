--- 1 ----------------------------------------------------------
-- Конвертирует стоимость объекта недвижимости в евро и долларах
----------------------------------------------------------------
CREATE OR REPLACE FUNCTION lab4_ex1(
	cost double precision
)
RETURNS TABLE (
	dol double precision,
	eur double precision
)
AS $$
SELECT 
cost/81.63 AS dol,
cost/89.66 AS eur
$$
LANGUAGE SQL;

SELECT *
FROM lab4_ex1(1000000);

--- 2 ----------------------------------------------------------
-- Рассчитывает заработную плату риэлтора по формуле: N*S+R, где
-- N – общая сумма проданных объектов недвижимости в месяц
-- (подсчет осуществляется автоматически по данным таблицы
-- «Продажи» с использованием агрегатной функции),
-- S – коэффициент, R – премия
----------------------------------------------------------------
CREATE OR REPLACE FUNCTION lab4_ex2(
	s double precision,
	r double precision,
	start_date date,
	end_date date,
	realtor_surname varchar)
RETURNS double precision
AS $$
SELECT 
(SELECT SUM(sales.cost) FROM sales JOIN realtors ON sales.realtor_id = 
realtors.id
WHERE realtors.s_name = realtor_surname AND sales.date BETWEEN start_date AND 
end_date) * s + r
$$
LANGUAGE SQL;

SELECT *
FROM lab4_ex2 (0.03,15000,'10.01.2017','10.02.2018','Сафронов');

--- 3 -----------------------------------------------------
-- Добавить таблицу «Заработная плата риэлтора», содержащая
-- сведения: год, месяц, размер выплаты. Изменить тело
-- функции из пункта 2 таким образом, чтобы рассчитанная
-- заработная плата сохранялась в этой таблице
-----------------------------------------------------------
---

--- 4 -------------------------------------------------------
-- Создать функцию, которая возвращает самые низкую и высокую
-- зарплаты необходимо месяца и года среди риэлторов
-------------------------------------------------------------
<Зависимость от номера 3>

--- 5 --------------------------------------------------------------------
-- Рассчитывает процент изменения продажной стоимости объекта недвижимости
-- от первоначально заявленной и срок продажи (в месяцах)
--------------------------------------------------------------------------
DROP FUNCTION IF EXISTS lab_4_ex_5(integer);
CREATE OR REPLACE FUNCTION lab_4_ex_5
(
	object_id integer
)
RETURNS TABLE
(
	diff_percent numeric,
	term_of_sale_month int
)
AS $$
SELECT
ROUND(((sales.cost / objects.cost - 1) * 100)::numeric, 2),
EXTRACT(month FROM AGE(sales.date, objects.date)) +
EXTRACT(year FROM AGE(sales.date, objects.date)) * 12
FROM
objects, sales
WHERE
objects.id = $1
AND
objects.id = sales.object_id
$$
LANGUAGE SQL;

SELECT *
FROM lab_4_ex_5(1);

--- 6 ----------------------------------------------------------
-- Изменить функцию, созданную в пункте 5 таким образом, чтобы в
-- зависимости от срока продажи выводилось сообщение
----------------------------------------------------------------


--- 7 ----------------------------------------------------
-- Формирует список средних оценок по каждому критерию для
-- объекта недвижимости
----------------------------------------------------------
CREATE OR REPLACE FUNCTION lab4_ex7(object_id bigint)
RETURNS TABLE (criteria_name varchar, avg_rate double precision)
AS $$
SELECT name, AVG(rate) 
FROM parameters JOIN rates
ON parameters.id = rates.parameter_id
JOIN objects ON objects.id = rates.object_id
WHERE objects.id = $1
GROUP BY name
$$
LANGUAGE SQL;

SELECT *
FROM lab4_ex7(1);

--- 8 ------------------------------------------------------------
-- Формирует список объектов недвижимости, стоимость 1м2 у которых
-- находится в заданном диапазоне и относящихся к конкретному типу
------------------------------------------------------------------
CREATE OR REPLACE FUNCTION lab_4_ex_8
(
	low_cost double precision,
	high_cost double precision,
	obj_type character varying(32)
)
RETURNS TABLE
(
	adress character varying(64),
	district character varying(32),
	rooms_num bigint
)
AS $$
SELECT objects.address, districts.name, objects.rooms
FROM
objects, districts, types
WHERE
objects.district_id = districts.id
AND
objects.type_id = types.id AND types.name = $3
AND
(objects.cost/objects.square) BETWEEN "low_cost" AND "high_cost"
$$
LANGUAGE SQL;

SELECT *
FROM lab_4_ex_8(100000, 500000, 'Квартира');

--- 9 -------------------------------------------------------
-- Рассчитывает процент изменения средней продажной стоимости
-- объектов недвижимости между годом №1 и годом №2.
-- Входные параметры: год 1, год 2, тип объекта недвижимости
-------------------------------------------------------------
CREATE OR REPLACE FUNCTION lab_4_ex_9(
IN start_year numeric,
IN end_year numeric,
IN type_id bigint,
OUT delta double precision
)
AS $$(
	SELECT (
	SELECT (
		SELECT AVG(sales.cost)
		FROM sales
		JOIN objects ON objects.id = sales.object_id
		WHERE objects.type_id = type_id
		AND EXTRACT(YEAR FROM sales.date) = start_year
	)
	/
	(
	SELECT (
		SELECT AVG(sales.cost)
		FROM sales
		JOIN objects ON objects.id = sales.object_id
		WHERE objects.type_id = type_id
		AND EXTRACT(YEAR FROM sales.date) = end_year
	)
	) - 1
	) * 100
)
$$
LANGUAGE SQL;

SELECT * FROM lab_4_ex_9(2017, 2020, 2)

--- 10 ------------------------------------------------------
-- Рассчитывает какой процент составляет площадь каждого типа
-- комнаты объекта недвижимости от общей площади.
-- Входной параметр: адрес квартиры
-------------------------------------------------------------
DROP FUNCTION IF EXISTS lab_4_ex_10(character varying(64));
CREATE OR REPLACE FUNCTION lab_4_ex_10
(
	object_address character varying(64)
)
RETURNS TABLE
(
	room_type integer,
	room_percent numeric,
	object_id integer
)
AS $$
SELECT
structures.room_type_id,
ROUND((objects.square / structures.square)::numeric, 2),
objects.id
FROM
objects, structures
WHERE
objects.address = $1
AND
objects.id = structures.object_id
$$
LANGUAGE SQL;

SELECT *
FROM lab_4_ex_10('Логвиново, дом 13, кв 3');

--- 11 -----------------------------------------------------
-- Определяет ФИО риэлторов, продавших квартиры, более чем в
-- двух районах.
-- Предусмотреть вывод ФИО в следующем формате: Иванов И.И.
------------------------------------------------------------


--- 12 ------------------------------------------
-- Определяет ФИО риэлторов, продавших квартиры в
-- одном районе (1), но не продавших в другом (2)
-- Входные параметры: название района 1 и 2
-------------------------------------------------
CREATE OR REPLACE FUNCTION lab4_ex12(district_1 varchar,district_2 varchar)
RETURNS TABLE (FIO varchar)
AS $$(
SELECT CONCAT(s_name,' ', f_name, ' ', t_name)
FROM realtors JOIN sales 
ON sales.realtor_id = realtors.id
JOIN objects ON objects.id = sales.object_id
JOIN districts ON districts.id = objects.district_id
WHERE districts.name = $1
)EXCEPT
(
SELECT CONCAT(s_name,' ', f_name, ' ', t_name)
FROM realtors JOIN sales 
ON sales.realtor_id = realtors.id
JOIN objects ON objects.id = sales.object_id
JOIN districts ON districts.id = objects.district_id
WHERE districts.name = $2)
$$
LANGUAGE SQL;

SELECT *
FROM lab4_ex12('Митино', 'ы');

--- 13 ---------------------------------------------
-- Формирует статистику по продажам за указанный год
-- Входные параметры: год
----------------------------------------------------
CREATE OR REPLACE FUNCTION lab_4_ex_13
(
	year int
)
RETURNS TABLE
(
	obj_type character varying(32),
	quantity smallint,
	part double precision,
	total_amount double precision
)
AS $$
SELECT
types.name, COUNT(*),
(
	COUNT(*) /
	(
	SELECT COUNT(*)
	FROM sales
	WHERE EXTRACT (YEAR FROM sales.date) = "year"
	)::double precision
) * 100,
SUM(sales.cost)
FROM
sales, objects, types
WHERE
objects.type_id = types.id
AND
sales.object_id = objects.id
AND
EXTRACT (YEAR FROM sales.date) = "year"
GROUP BY types.name
$$
LANGUAGE SQL;

SELECT *
FROM lab_4_ex_13(2022);

--- 14 ------------------------------------------------------------------------
-- Написать функцию, которая рассчитывает сумму ежемесячного платежа по ипотеке
-- Входные параметры:
-- код объекта недвижимости, процентная ставка, срок, первоначальный взнос
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION lab_4_ex_14 (
	IN object_id int,
	IN perc double precision,
	IN term int,
	IN initial_pay int,
	OUT month_pay double precision
)
AS $$
SELECT (cost - initial_pay) * ((perc/100/12 * POWER(1 + perc/100/12, term)) / (POWER(1 + perc/12/100, term)-1))
FROM objects
WHERE objects.id = object_id
$$
LANGUAGE SQL;

SELECT * FROM lab_4_ex_14(6, 4, 12, 200000)

--- 15 ---------------------------------------------------------------
-- Написать функцию, которая рассчитывает сумму налога на недвижимость
-- Входные параметры: ставка, размер доли
----------------------------------------------------------------------
CREATE OR REPLACE FUNCTION lab_4_ex_15
(
	obj_id integer,
	rate double precision,
	part double precision
)
RETURNS double precision
AS $$
SELECT
objects.cost * "part" / 100 * "rate" / 100
FROM objects
WHERE objects.id = "obj_id"
$$
LANGUAGE SQL;

SELECT * FROM lab_4_ex_15(1, 13, 100);
