---------------------
-- Создание таблиц --
---------------------
-- types
DROP TABLE IF EXISTS types CASCADE;
CREATE TABLE IF NOT EXISTS types (
	type_id SERIAL PRIMARY KEY,
	name varchar(32)
);

-- districts
DROP TABLE IF EXISTS districts CASCADE;
CREATE TABLE IF NOT EXISTS districts (
	district_id SERIAL PRIMARY KEY,
	name varchar(32)
);

-- building materials
DROP TABLE IF EXISTS bm CASCADE;
CREATE TABLE IF NOT EXISTS bm (
	bm_id SERIAL PRIMARY KEY,
	name varchar(32)
);

-- real estate object
DROP TABLE IF EXISTS reo CASCADE;
CREATE TABLE IF NOT EXISTS reo (
	reo_id SERIAL PRIMARY KEY,
	district_id bigint references districts(district_id),
	address varchar(32),
	floor bigint,
	rooms_count bigint,
	type_id bigint references types(type_id),
	status boolean,
	cost double precision,
	object_desc text,
	bm_id bigint references bm(bm_id),
	square double precision,
	date date
);

-- evaluation criteria
DROP TABLE IF EXISTS ec CASCADE;
CREATE TABLE IF NOT EXISTS ec (
	ec_id SERIAL PRIMARY KEY,
	name varchar(32)
);

-- evaluations
DROP TABLE IF EXISTS eva CASCADE;
CREATE TABLE IF NOT EXISTS eva (
	eva_id SERIAL PRIMARY KEY,
	reo_id bigint references reo(reo_id),
	date date,
	ec_id bigint references ec(ec_id),
	score double precision
);

-- realtors
DROP TABLE IF EXISTS realtors CASCADE;
CREATE TABLE IF NOT EXISTS realtors (
	realtor_id SERIAL PRIMARY KEY,
	s_name varchar(32),
	f_name varchar(32),
	t_name varchar(32),
	phone_num varchar(16)
);

-- sales
DROP TABLE IF EXISTS sales CASCADE;
CREATE TABLE IF NOT EXISTS sales (
	sale_id SERIAL PRIMARY KEY,
	reo_id bigint references reo(reo_id),
	date date,
	realtor_id bigint references realtors(realtor_id),
	cost double precision
);

-----------------------
-- Заполнение таблиц --
-----------------------
-- «Тип» - types
INSERT INTO types VALUES
(1, 'Квартира'),
(2, 'Дом'),
(3, 'Апартаменты'),
(4, 'Трущебы');

-- «Районы» - districts
INSERT INTO districts VALUES
(1, 'Ленинский'),
(2, 'Митино'),
(3, 'Марьино'),
(4, 'Гольяново');

-- «Материалы зданий» - bm
INSERT INTO bm VALUES
(1, 'панель'),
(2, 'кирпич'),
(3, 'пена'),
(4, 'дерево');


-- «Объект недвижимости» - reo
INSERT INTO reo
(district_id, address, floor, rooms_count, type_id, status, cost, object_desc, bm_id, square, date)
VALUES
(1,'ул. Олегова', 2, 1, 1, FALSE, 100000, 'Великолепно', 1, 20, '10.03.2005'),
(2,'ул. Савушкина 3 кв.25',2,2,1, TRUE,1000000,'Превосходная квартира', 3, 30.5,'12.03.2017'),
(3,'ул. Едисеева', 3, 6, 4, TRUE, 12344556, 'Ужасно', 3, 40, '10.02.2006'),
(4,'ул. Самойлова', 3, 4, 2, TRUE, 7458584, 'Отвратительно', 2, 23, '11.03.2015'),
(4,'ул. Ушакова', 4, 2, 4, TRUE, 10758499, 'Плохо', 1, 10, '19.08.2009'),
(3,'ул. Голодяева', 2, 3, 1, FALSE, 1000066, 'Хорошо', 4, 50, '10.12.2012'),
(3,'ул. Ушакова', 2, 2, 1, FALSE, 10486900, 'Великолепно', 1, 27, '10.11.2018'),
(1,'ул. Едисеева', 17, 3, 3, FALSE, 149684090, 'Хорошо', 2, 29, '20.10.2015'),
(1,'ул. Ушакова', 15, 4, 3, FALSE, 109495, 'Плохо', 3, 46, '30.05.2006'),
(2,'ул. Ушакова', 13, 4, 2, TRUE, 10007775, 'Ужасно', 1, 42, '12.05.2004'),
(2,'ул. Ушакова', 11, 6, 1, TRUE, 19504850, 'Великолепно', 2, 38, '27.06.2008'),
(1,'ул. Едисеева', 12, 3, 4, FALSE, 1045674, 'Плохо', 2, 24, '24.03.2005'),
(3,'ул. Никитина', 6, 6, 3, TRUE, 149869, 'Невероятно', 4, 52, '10.06.2005'),
(4,'ул. Голодяева', 7, 1, 3, FALSE, 5960485, 'Невероятно', 2, 60, '17.03.2002'),
(1,'ул. Голодяева', 6, 1, 3, TRUE, 505857494, 'Великолепно', 3, 50, '14.08.2012'),
(2,'ул. Самойлова', 2, 2, 1, FALSE, 9465849, 'Ужасно', 1, 33, '10.03.2014'),
(4,'ул. Олегова', 9, 3, 1, TRUE, 76584986, 'Хорошо', 4, 87, '10.05.2014'),
(3,'ул. Никитина', 3, 3, 3, TRUE, 58579559, 'Хорошо', 3, 89, '10.06.2014'),
(1,'ул. Едисеева', 2, 2, 2, TRUE, 678495, 'Великолепно', 1, 47, '26.09.2005'),
(2,'ул. Ушакова', 5, 3, 3, FALSE, 10979540, 'Великолепно', 2, 78, '21.03.2005'),
(3,'ул. Ушакова', 9, 5, 4, TRUE, 5758347386, 'Хорошо', 3, 44, '20.05.2008'),
(2,'ул. Олегова', 18, 4, 4, FALSE, 7859960, 'Великолепно', 2, 55, '10.03.2009'),
(1,'ул. Голодяева', 19, 2, 3, TRUE, 68896946, 'Ужасно', 3, 70, '19.06.2005'),
(4,'ул. Голодяева', 15, 3, 4, TRUE, 685584970, 'Отвратительно', 3, 80, '16.03.2007'),
(4,'ул. Никитина', 13, 5, 1, TRUE, 8685594, 'Отвратительно', 4, 200, '10.07.2007'),
(4,'ул. Ушакова', 14, 3, 2, TRUE, 67648695, 'Великолепно', 4, 100, '13.03.2001'),
(4,'ул. Голодяева', 18, 2, 2, TRUE, 358643, 'Плохо', 3, 20, '11.04.2002'),
(3,'ул. Олегова', 8, 4, 3, FALSE, 33333333, 'Великолепно', 2, 45, '10.03.2015'),
(2,'ул. Самойлова', 9, 3, 3, TRUE, 767676767, 'Ужасно', 1, 70, '17.08.2015'),
(3,'ул. Самойлова', 100, 1000, 3, TRUE, 9999999999999, 'Хорошо', 4, 100000, '19.09.2005'),
(2,'ул. Олегова', 2, 2, 2, TRUE, 1111111, 'Великолепно', 2, 30, '10.02.2008'),
(3,'ул. Никитина', 2, 2, 2, TRUE, 1231241241, 'Плохо', 2, 30, '18.06.2008'),
(1,'ул. Самойлова', 3, 2, 2, FALSE, 10004324, 'Великолепно', 2, 30, '18.01.2008'),
(4,'ул. Сафронова', 4, 2, 2, TRUE, 50003403, 'Ужасно', 2, 30, '22.09.2008');

-- «Критерии оценки» - ec
INSERT INTO ec (name) VALUES
('экология'),
('чистота'),
('соседи'),
('условия для детей'),
('магазины'),
('безопасность');

-- «Оценки» - eva
INSERT INTO eva (reo_id, date, ec_id, score) VALUES
(12,'28.03.2017',1,3.5),
(15,'27.04.2017',2,3.6),
(27,'26.05.2017',3,3.7),
(12,'25.06.2017',4,3.8),
(31,'24.07.2017',5,3.9),
(21,'23.08.2017',6,4.0),
(5,'22.09.2017',6,4.1),
(6,'21.10.2017',6,4.2),
(8,'19.11.2017',5,4.3),
(11,'18.12.2017',4,4.4),
(9,'17.12.2017',3,4.5),
(12,'16.11.2017',4,4.6),
(8,'20.10.2017',1,4.7),
(16,'16.10.2017',1,4.8),
(10,'13.08.2017',2,4.9),
(1,'12.07.2017',3,5.0),
(2,'11.06.2017',4,4.9),
(3,'10.05.2017',4,4.8),
(4,'09.04.2017',6,4.7),
(5,'08.03.2017',4,4.6),
(6,'07.02.2017',5,4.5),
(7,'06.01.2017',4,4.4),
(8,'05.01.2017',3,4.3),
(9,'04.02.2017',2,4.2);

-- «Риэлтор» - realtors
INSERT INTO realtors
(s_name, f_name, t_name, phone_num) VALUES
('Иванов', 'Иван', 'Петрович', '89608521245'),
('Кузнецов', 'Антон', 'Васильевич', '12234567899'),
('Продолговатый', 'Петр', 'Лисов', '98765432101'),
('Меньших', 'Афанасий', 'Евгеньевич', '65784932013'),
('Аккредитованный', 'Георгий', 'Колобков', '89690137888');

-- «Продажи» - sales
INSERT INTO sales
(reo_id, date, realtor_id, cost) VALUES
(1, '28.03.2017', 4, 10000.10),
(2, '28.04.2017', 3, 20000.10),
(3, '28.05.2017', 2, 30000.10),
(4, '28.06.2017', 1, 40000.10),
(5, '28.07.2017', 1, 50000.10),
(6, '28.08.2017', 2, 60000.10),
(7, '23.10.2017', 3, 70000.10),
(8, '24.10.2017', 4, 70000.10),
(9, '28.11.2017', 5, 80000.10),
(10, '28.12.2017', 5,880000.10),
(11, '27.12.2017', 4, 820000.10),
(12, '26.12.2017', 3, 804000.10),
(31, '25.12.2017', 2, 5800500.10),
(13, '24.12.2017', 1, 810000.10),
(14, '23.12.2017', 1, 80124000.10),
(15, '22.12.2017', 2, 800050.10),
(16, '21.12.2017', 3, 181100004.10);

-------------
-- Запросы --
-------------

--- 1 ------------------------------------------------------
-- Вывести все панельные объекты недвижимости, расположенные
-- на указанном этаже и статусом «в продаже»
------------------------------------------------------------
SELECT
reo.address, reo.object_desc, reo.date, districts.name
FROM
reo, districts
WHERE
districts.district_id = reo.district_id
AND
reo.floor = 2
AND
reo.status = TRUE;

--- 2 ---------------------------------------------------
-- Вывести квартиры с площадью более указанного значения,
-- расположенные в указанном районе
---------------------------------------------------------
SELECT
reo.address, reo.object_desc
FROM
reo, districts, types
WHERE
types.name = 'Квартира'
AND
reo.type_id = types.type_id
AND
reo.square > 30
AND
reo.district_id = districts.district_id
AND
districts.name = 'Митино';

--- 3 --------------------------------------------------
-- Вывести дома, имеющие более 2 комнат, расположенные в
-- указанном районе
--------------------------------------------------------
SELECT
reo.address, reo.floor, reo.rooms_count
FROM
reo, districts, types
WHERE
types.name = 'Дом'
AND
reo.type_id = types.type_id
AND
reo.rooms_count > 2
AND
reo.district_id = districts.district_id
AND
districts.name = 'Митино';

--- 4 --------------------------------------------------------
-- Вывести квартиры, расположенные в панельном доме на 2 этаже
-- стоимостью менее указанного значения
--------------------------------------------------------------
SELECT
reo.address, reo.object_desc, reo.rooms_count
FROM
reo, bm, types
WHERE
types.name = 'Квартира' AND reo.type_id = types.type_id
AND
bm.name = 'панель' AND reo.bm_id = bm.bm_id
AND
reo.floor = 2
AND
reo.cost < 2000000;

--- 5 ---------------------------------------------------
-- Вывести фамилии риэлтор, которые продали двухкомнатные
-- объекты недвижимости
---------------------------------------------------------
SELECT DISTINCT
realtors.s_name, realtors.f_name, realtors.t_name
FROM
realtors, reo, sales
WHERE
reo.reo_id = sales.reo_id
AND
sales.realtor_id = realtors.realtor_id
AND
reo.rooms_count = 2;

--- 6 -------------------------------------------------------
-- Выбрать список квартир, проданных риэлтором выше указанной
-- продажной стоимости
-------------------------------------------------------------
SELECT DISTINCT
reo.address, reo.floor, reo.rooms_count
FROM
reo, realtors, sales, types
WHERE
types.type_id = reo.type_id
AND
types.name = 'Квартира'
AND
reo.reo_id = sales.reo_id
AND
sales.realtor_id = realtors.realtor_id
AND
sales.cost > 2000000
AND
realtors.s_name = 'Иванов';

--- 7 ----------------------------------------------------------
-- Выбрать двухкомнатные объекты недвижимости, у которых имеется
-- оценка по критерию «Условие для детей»
----------------------------------------------------------------
SELECT DISTINCT
reo.address, districts.name, types.name
FROM
reo, districts, types, ec, eva
WHERE
reo.district_id = districts.district_id
AND
reo.type_id = types.type_id
AND
reo.rooms_count = 2
AND
eva.reo_id = reo.reo_id
AND
ec.ec_id = eva.ec_id
AND
ec.name = 'условия для детей';

--- 8 ----------------------------------------------------
-- Вывести разницу между заявленной и продажной стоимостью
-- объектов недвижимости, расположенных на 2 этаже
----------------------------------------------------------
SELECT
reo.address, reo.cost - sales.cost, realtors.f_name, realtors.s_name, realtors.t_name
FROM
reo, sales, realtors
WHERE
reo.floor = 2
AND
sales.reo_id = reo.reo_id
AND
sales.realtor_id = realtors.realtor_id;

--- 9 ------------------------------------------------------
-- Определить среднюю стоимость дома с указанным количеством
-- комнат и площадью
------------------------------------------------------------
SELECT
AVG(reo.cost)
FROM 
reo, types
WHERE
reo.type_id = types.type_id
AND
types.name = 'Дом'
AND
reo.rooms_count = 2
AND
reo.square = 30;

--- 10 -----------------------------------------------
-- Определить максимальную продажную стоимость объекта
-- недвижимости, проданного указанным риэлтором
------------------------------------------------------
SELECT
MAX(sales.cost)
FROM
sales, realtors
WHERE
realtors.s_name = 'Иванов'
AND
sales.realtor_id = realtors.realtor_id;

--- 11 ------------------------------------------------
-- Определить минимальную продажную стоимость квартиры,
-- проданной в диапазоне дат «ОТ» и «ДО»
-------------------------------------------------------
SELECT
MIN(sales.cost)
FROM
sales, reo, types
WHERE
reo.type_id = types.type_id AND types.name = 'Квартира'
AND
sales.reo_id = reo.reo_id
AND
sales.date > '20.10.2017'
AND
sales.date < '25.10.2017';

--- 12 --------------------------------------------
-- Определить среднюю оценку объектов недвижимости,
-- расположенных в указанном районе
---------------------------------------------------
SELECT
AVG(reo.cost)
FROM
reo, districts
WHERE
reo.district_id = districts.district_id
AND
districts.name = 'Марьино';

--- 13 ---------------------------------------------------------
-- Определить среднюю оценку квартир панельного дома с указанным
-- количеством комнат
----------------------------------------------------------------
SELECT
AVG(reo.cost)
FROM
reo, types, bm
WHERE
reo.bm_id = bm.bm_id AND bm.name = 'панель'
AND
reo.type_id = types.type_id AND types.name = 'Квартира'
AND
reo.rooms_count = 2;

--- 14 --------------------------------------
-- Определить среднюю оценку дома по критерию
-- «Условия для детей»
---------------------------------------------
SELECT
AVG(eva.score)
FROM
reo, types, ec, eva
WHERE
reo.type_id = types.type_id AND types.name = 'Квартира'
AND
eva.reo_id = reo.reo_id
AND
eva.ec_id = ec.ec_id AND ec.name = 'условия для детей';

--- 15 ----------------------------------------------
-- Определить среднюю оценку апартаментов по критерию
-- «Безопасность», проданных указанным риэлтором
-----------------------------------------------------
SELECT
AVG(eva.score)
FROM
reo, types, ec, eva, realtors, sales
WHERE
reo.type_id = types.type_id AND types.name = 'Квартира'
AND
eva.reo_id = reo.reo_id
AND
eva.ec_id = ec.ec_id AND ec.name = 'условия для детей'
AND
reo.reo_id = sales.reo_id AND sales.realtor_id = realtors.realtor_id
AND
realtors.f_name = 'Афанасий';

--- 16 ---------------------------------------------------
-- Определить среднюю продажную стоимость 1м2 для квартир,
-- которые были проданы в указанную дату «ОТ» и «ДО»
----------------------------------------------------------
SELECT
AVG(sales.cost / reo.square)
FROM
sales, reo, types
WHERE
reo.type_id = types.type_id AND types.name = 'Квартира'
AND
sales.reo_id = reo.reo_id
AND
sales.date > '20.10.2017'
AND
sales.date < '25.10.2017';

--- 17 ----------------------------------------------
-- Определить максимальную стоимость 1м2 для квартир,
-- расположенных в указанном районе.
-----------------------------------------------------
SELECT
MAX(sales.cost / reo.square)
FROM
sales, reo, types, districts
WHERE
reo.type_id = types.type_id AND types.name = 'Квартира'
AND
reo.district_id = districts.district_id AND districts.name = 'Митино';

--- 18 --------------------------------------------------
-- Определите количество объектов недвижимости, проданных
-- указанным риэлтором
---------------------------------------------------------
SELECT
COUNT(reo.reo_id)
FROM
reo, realtors, sales
WHERE
sales.reo_id = reo.reo_id AND sales.realtor_id = realtors.realtor_id
AND
realtors.f_name = 'Иван';

--- 19 -------------------------------------------------
-- Определить максимальную площадь объекта недвижимости,
-- продаваемого по указанной стоимости
--------------------------------------------------------
SELECT
MAX(reo.square)
FROM
reo, sales
WHERE
sales.reo_id = reo.reo_id
AND
sales.cost > 10000000;

--- 20 -----------------------------------------------------
-- Определить квартиры, у которых разница между заявленной и
-- продажной стоимостью является максимальной
------------------------------------------------------------
SELECT
MAX(reo.cost - sales.cost)
FROM
reo, sales, types
WHERE
reo.type_id = types.type_id AND types.name = 'Квартира'
AND
sales.reo_id = reo.reo_id;