---------------------
-- Создание таблиц --
---------------------
-- «Тип» - types
DROP TABLE IF EXISTS types CASCADE;
CREATE TABLE IF NOT EXISTS types (
	id SERIAL PRIMARY KEY,
	name varchar(32)
);

-- «Районы» - districts
DROP TABLE IF EXISTS districts CASCADE;
CREATE TABLE IF NOT EXISTS districts (
	id SERIAL PRIMARY KEY,
	name varchar(32)
);

-- «Материалы зданий» - materials
DROP TABLE IF EXISTS materials CASCADE;
CREATE TABLE IF NOT EXISTS materials (
	id SERIAL PRIMARY KEY,
	name varchar(32)
);

-- «Объекты недвижимости» - objects
DROP TABLE IF EXISTS objects CASCADE;
CREATE TABLE IF NOT EXISTS objects (
	id SERIAL PRIMARY KEY,
	district_id bigint references districts(id),
	address varchar(64),
	floor bigint,
	rooms bigint,
	type_id bigint references types(id),
	status boolean,
	cost double precision,
	description text,
	material_id bigint references materials(id),
	square double precision,
	date date
);

-- «Критерии оценки» - parameters
DROP TABLE IF EXISTS parameters CASCADE;
CREATE TABLE IF NOT EXISTS parameters (
	id SERIAL PRIMARY KEY,
	name varchar(32)
);

-- «Оценки» - rates
DROP TABLE IF EXISTS rates CASCADE;
CREATE TABLE IF NOT EXISTS rates (
	id SERIAL PRIMARY KEY,
	object_id bigint references objects(id),
	date date,
  parameter_id bigint references parameters(id),
	rate double precision
);

-- «Риелторы» - realtors
DROP TABLE IF EXISTS realtors CASCADE;
CREATE TABLE IF NOT EXISTS realtors (
	id SERIAL PRIMARY KEY,
	s_name varchar(32),
	f_name varchar(32),
	t_name varchar(32),
	contacts varchar(16)
);

-- «Продажи» - sales
DROP TABLE IF EXISTS sales CASCADE;
CREATE TABLE IF NOT EXISTS sales (
	id SERIAL PRIMARY KEY,
	object_id bigint references objects(id),
	date date,
	realtor_id bigint references realtors(id),
	cost double precision
);

-- «Структуры квартир» - structures
DROP TABLE IF EXISTS structures CASCADE;
CREATE TABLE IF NOT EXISTS structures (
	object_id bigint references objects(id),
	room_type_id bigint CHECK (room_type_id > 0 AND room_type_id < 5),
	square double precision CHECK (square > 0)
);

-- «Зарплаты риелторов» -- realtors_salary
DROP TABLE IF EXISTS realtors_salary;
CREATE TABLE realtors_salary
(
	realtor_id bigint references realtors(id),
	month smallint,
	year smallint,
	salary double precision
);

-- «Бонусы» -- bonuses
DROP TABLE IF EXISTS bonuses CASCADE;
CREATE TABLE bonuses
(
	realtor_id bigint references realtors(id),
	bonus double precision
);