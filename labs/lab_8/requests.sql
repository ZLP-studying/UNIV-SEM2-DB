-- 1 -------------------------------------------------------
-- Добавьте в таблицу РИЭЛТОР новые поля:
-- ОПОЗДАНИЯ (тип данных: interval),
-- СВЕРХУРОЧНЫЕ (тип данных: interval).
------------------------------------------------------------
ALTER TABLE realtors
ADD COLUMN late_arrivals 	interval DEFAULT (interal '0'),
ADD COLUMN overtime       interval DEFAULT (interval '0');

-- 2 ------------------------------------------------------------------------------------------
-- Создайте таблицу РАБОЧИЙ ДЕНЬ, в которой будет храниться информация о входе/выходе
-- сотрудника через систему контроля доступа посредством электронной карты. Считается, что
-- в таблице хранятся данные за один месяц. Для каждого сотрудника фиксируется время входа
-- (значение = 1), время выхода (значение = 2). Рабочий день начинается в 9.00 часов и закан-
-- чивается в 18.00 часов. Время обеда: с 13.00 до 14.00 часов. Работа до 09.00 и после 18.00
-- часов является сверхурочной. Опоздание – это вход позднее 9.00 часов, уход на обед до 13.00,
-- возвращение с обеда после 14.00, уход в конце рабочего дня до 18.00 часов. Время входа/вы-
-- хода должно храниться в виде поля типа DATETIME.
-----------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS weekdays CASCADE;
CREATE TABLE IF NOT EXISTS weekdays(
	id serial PRIMARY KEY,
	realtor_id bigint REFERENCES realtors (id),
	action_time timestamp,
	action_type integer
);

INSERT INTO weekdays
(realtor_id,action_time,action_type)
VALUES
-- вход --
(1,'2023-01-01,08:59:33',1),
(2,'2023-01-01,11:21:10',1),
(3,'2023-01-01,09:15:52',1),
(4,'2023-01-01,07:56:01',1),
(5,'2023-01-01,08:56:14',1),

-- выход --
(1,'2023-01-01,20:02:17',2),
(2,'2023-01-01,17:11:19',2),
(3,'2023-01-01,18:00:29',2),
(4,'2023-01-01,18:16:37',2),
(5,'2023-01-01,18:05:54',2),

-- выход на обед --
(1,'2023-01-01,13:01:12',2),
(2,'2023-01-01,13:01:25',2),
(3,'2023-01-01,13:01:36',2),
(4,'2023-01-01,12:42:33',2),
(5,'2023-01-01,13:01:50',2),

-- вход после обеда--
(1,'2023-01-01,13:46:02',1),
(2,'2023-01-01,13:51:10',1),
(3,'2023-01-01,13:51:26',1),
(4,'2023-01-01,13:46:08',1),
(5,'2023-01-01,14:06:11',1),

-- остальное --
(1,'2023-01-01,16:30:44',2),
(4,'2023-01-01,16:30:56',2),
(5,'2023-01-01,16:31:08',2),
(1,'2023-01-01,16:35:01',1),
(4,'2023-01-01,16:35:26',1),
(5,'2023-01-01,16:35:13',1);

-- 3 -------------------------------------------------------
-- Создайте процедуры, с помощью которых выполняются следующие расчеты:

-- 1. в таблице РИЭЛТОРЫ обновляются поля ОПОЗДАНИЯ и СВЕРХУРОЧНЫЕ на
-- основании информации из таблицы РАБОЧИЙ ДЕНЬ. В указанных столбцах должно
-- храниться для каждого сотрудника суммарное время опозданий и сверхурочных.
-- Приотсутствии опозданий/сверхурочных в соответствующее поле заносится ноль.

-- 2. определяются фамилии сотрудников, которые отработали меньше 40 часов в неделю.

-- 3. производится расчет заработной платы сотрудников по формуле:
-- ЗАРПЛАТА=OKLAD + OKLAD*A*В + С + D + E
-- A:
-- По умолчанию А=1, работник должен отработать 40 часов в неделю.
-- Если работник отработал меньше:
-- а) За каждые 10 мин. опоздания А уменьшается на 0,05
-- б) За опоздание более 60 мин. за каждые 10 мин. опоздания А уменьшается на 0,2
-- B:
-- За каждые 60 мин. сверхурочной работы оклад увеличивается на 10%,
-- при условии, что у сотрудника нет опозданий.
-- C:
-- Для сотрудников, имеющих в своем отделе оклад меньше среднего по отделу,
-- установить доплату в размере 500 руб, для остальных – в размере 200 руб.
-- D:
-- Если в отделе нет ни одного сотрудника, опоздавшего на работу, то каждому сотруднику
-- данного отдела устанавливается дополнительная доплата в размере 300 руб.
-- E:
-- Для каждого четного номера месяца установить премию в размере 25% от оклада каждому
-- сотруднику, имеющему четный ранг по окладу на предприятии, для каждого нечетного
-- месяца – каждому сотруднику с нечетным рангом.
------------------------------------------------------------
CREATE OR REPLACE FUNCTION realtor_work_update()
RETURNS TRIGGER
AS $$
DECLARE
    a_time time;
    work_start time := '09:00:00';
    work_end time := '18:00:00';
    lunch_start time := '13:00:00';
    lunch_end time := '14:00:00';
BEGIN
    a_time := NEW.action_time::time;

    IF NEW.action_type = 1 THEN
        IF a_time > work_start AND a_time < lunch_start THEN
            UPDATE realtors SET late_arrivals = (SELECT late_arrivals FROM realtors WHERE id = NEW.realtor_id) + (a_time - work_start) WHERE id = NEW.realtor_id;
        ELSIF a_time > lunch_end AND a_time < work_end THEN
            UPDATE realtors SET late_arrivals = (SELECT late_arrivals FROM realtors WHERE id = NEW.realtor_id) + (a_time - lunch_end) WHERE id = NEW.realtor_id;
        ELSIF a_time < work_start THEN
            UPDATE realtors SET overtime = (SELECT overtime FROM realtors WHERE id = NEW.realtor_id) + (work_start - a_time) WHERE id = NEW.realtor_id;
		END IF;
    ELSIF NEW.action_type = 2 THEN
        IF a_time > work_end THEN
            UPDATE realtors SET overtime = (SELECT overtime FROM realtors WHERE id = NEW.realtor_id) + (a_time - work_end) WHERE id = NEW.realtor_id;
        ELSIF a_time > lunch_start AND a_time < lunch_end THEN
            UPDATE realtors SET overtime = (SELECT overtime FROM realtors WHERE id = NEW.realtor_id) + (a_time - lunch_start) WHERE id = NEW.realtor_id;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER realtor_work_update
AFTER INSERT ON weekdays
FOR EACH ROW
EXECUTE FUNCTION realtor_work_update();

INSERT INTO weekdays
(realtor_id,action_time,action_type)
VALUES
(5,'2023-01-01,21:00:00',2)

select * from weekdays
select * from realtors

-- function_that_finds_bad_worker --

INSERT INTO weekdays
(realtor_id,action_time,action_type)
VALUES
/*
realtor_id = 2 - bad worker
realtor_id = 1 - good worker
*/
-- вход --
(1,'2019-01-01,08:59:33',1),
(2,'2019-01-01,11:21:10',1),
(1,'2019-01-02,08:59:33',1),
(2,'2019-01-02,11:21:10',1),
(1,'2019-01-03,08:59:33',1),
(2,'2019-01-03,11:21:10',1),
(1,'2019-01-04,08:59:33',1),
(2,'2019-01-04,11:21:10',1),
(1,'2019-01-05,08:59:33',1),
(2,'2019-01-05,11:21:10',1),

-- выход --
(1,'2019-01-01,20:00:00',2),
(2,'2019-01-01,17:00:00',2),
(1,'2019-01-02,20:00:00',2),
(2,'2019-01-02,17:00:00',2),
(1,'2019-01-03,20:00:00',2),
(2,'2019-01-03,17:00:00',2),
(1,'2019-01-04,20:00:00',2),
(2,'2019-01-04,17:00:00',2),
(1,'2019-01-05,20:00:00',2),
(2,'2019-01-05,17:00:00',2),

-- выход на обед --
(1,'2019-01-01,13:01:00',2),
(2,'2019-01-01,12:00:00',2),
(1,'2019-01-02,13:01:00',2),
(2,'2019-01-02,12:00:00',2),
(1,'2019-01-03,13:01:00',2),
(2,'2019-01-03,12:00:00',2),
(1,'2019-01-04,13:01:00',2),
(2,'2019-01-04,12:00:00',2),
(1,'2019-01-05,13:01:00',2),
(2,'2019-01-05,12:00:00',2),

-- вход после обеда --
(1,'2019-01-01,13:45:00',1),
(2,'2019-01-01,14:10:00',1),
(1,'2019-01-02,13:45:00',1),
(2,'2019-01-02,14:10:00',1),
(1,'2019-01-03,13:45:00',1),
(2,'2019-01-03,14:10:00',1),
(1,'2019-01-04,13:45:00',1),
(2,'2019-01-04,14:10:00',1),
(1,'2019-01-05,13:45:00',1),
(2,'2019-01-05,14:10:00',1);

CREATE OR REPLACE FUNCTION detect_bad_worker(week_start date)
RETURNS SETOF bigint
AS $$
DECLARE
	realtor_temp bigint;
BEGIN
	FOR realtor_temp IN (SELECT id FROM realtors)
	LOOP
		IF (SELECT ((SELECT SUM(action_time::TIME) FROM weekdays WHERE realtor_id = realtor_temp AND
			ABS(action_time::DATE - week_start) < 7 AND action_type = 2)  -
				(SELECT SUM(action_time::TIME) FROM weekdays WHERE realtor_id = realtor_temp AND
			ABS(action_time::DATE - week_start) < 7 AND action_type = 1))) < '40:00:00' THEN
			RETURN NEXT realtor_temp;
		END IF;	
	END LOOP;
END;
$$ LANGUAGE plpgsql;

select detect_bad_worker('2019-01-01');

-- salary_counter --
ALTER TABLE realtors
ADD COLUMN base_salary money DEFAULT (0);

DELETE FROM weekdays *;

UPDATE realtors SET base_salary = 10000 WHERE id = 1;
UPDATE realtors SET base_salary = 10000 WHERE id = 2;
UPDATE realtors SET base_salary = 10000 WHERE id = 3;
UPDATE realtors SET base_salary = 10000 WHERE id = 4;
UPDATE realtors SET base_salary = 10000 WHERE id = 5;

UPDATE realtors SET late_arrivals = '00:00:00' WHERE id = 1;
UPDATE realtors SET late_arrivals = '00:00:00' WHERE id = 2;
UPDATE realtors SET late_arrivals = '00:00:00' WHERE id = 3;
UPDATE realtors SET late_arrivals = '00:00:00' WHERE id = 4;
UPDATE realtors SET late_arrivals = '00:00:00' WHERE id = 5;

UPDATE realtors SET overtime = '00:00:00' WHERE id = 1;
UPDATE realtors SET overtime = '00:00:00' WHERE id = 2;
UPDATE realtors SET overtime = '00:00:00' WHERE id = 3;
UPDATE realtors SET overtime = '00:00:00' WHERE id = 4;
UPDATE realtors SET overtime = '00:00:00' WHERE id = 5;

SELECT * FROM realtors;

CREATE OR REPLACE FUNCTION salary(month_num integer)
RETURNS TABLE(id integer, salary_total money)
AS $$
DECLARE
salary_total money := 0;
pa float;
pb float;
pc money;
pd money;
pe float;
realtor_temp integer;
rang_counter int := 0;
salary_temp money;
BEGIN
	FOR realtor_temp IN (SELECT realtors.id FROM realtors ORDER BY base_salary DESC)
	LOOP
		rang_counter := rang_counter + 1;
		--A-----------------------------------------------------------------------------------------
		IF (SELECT late_arrivals FROM realtors WHERE realtors.id = realtor_temp) > '01:00:00' THEN
			pa := 1 - 0.2 * FLOOR(EXTRACT(EPOCH FROM (select late_arrivals from realtors where realtors.id = realtor_temp)/600));
		ELSIF (SELECT late_arrivals FROM realtors WHERE realtors.id = realtor_temp) = '00:00:00' THEN
			pa := 1;
		ELSE
			pa := 1 - 0.05 * FLOOR(EXTRACT(EPOCH FROM realtors.late_arrivals)/600);
		END IF;

		--B-----------------------------------------------------------------------------------------
		IF (SELECT late_arrivals FROM realtors WHERE realtors.id = realtor_temp) = '00:00:00' THEN
			pb := 1 + 0.1*FLOOR(EXTRACT(EPOCH FROM (SELECT overtime FROM realtors WHERE realtors.id = realtor_temp))/3600);
		ELSE
			pb := 1;
		END IF;

		--C-----------------------------------------------------------------------------------------
		IF (SELECT base_salary FROM realtors WHERE realtors.id = realtor_temp) < CAST((SELECT AVG(CAST(base_salary as NUMERIC)) FROM realtors) AS MONEY) THEN
			pc := 500;
		ELSE 
			pc := 200;
		END IF;

		--D-----------------------------------------------------------------------------------------
		IF (SELECT SUM(overtime) FROM REALTORS) = '00:00:00' THEN
			pd := 300;
		ELSE
			pd := 0;
		END IF;

		--E-----------------------------------------------------------------------------------------
		IF rang_counter % 2 = 1 and month_num % 2 = 1 THEN
			pe := 0.25;
		ELSIF rang_counter % 2 = 0 and month_num % 2 = 0 THEN
			pe := 0.25;
		ELSE
			pe := 0;
		END IF;

		salary_temp = (SELECT base_salary FROM realtors WHERE realtors.id = realtor_temp);
		salary_total = salary_temp + salary_temp * pa * pb + pc + pd + salary_temp*pe;

		RETURN QUERY SELECT realtor_temp, salary_total;		
	END LOOP;
END;
$$ LANGUAGE plpgsql;


INSERT INTO weekdays
(realtor_id,action_time,action_type)
VALUES
-- Day 1
(1, TIMESTAMP '2023-05-01 09:00:00', 1),
(1, TIMESTAMP '2023-05-01 13:00:00', 2),
(1, TIMESTAMP '2023-05-01 14:00:00', 1),
(1, TIMESTAMP '2023-05-01 18:00:00', 2),
-- Day 2
(1, TIMESTAMP '2023-05-02 09:00:00', 1),
(1, TIMESTAMP '2023-05-02 13:00:00', 2),
(1, TIMESTAMP '2023-05-02 14:00:00', 1),
(1, TIMESTAMP '2023-05-02 18:00:00', 2),
-- Day 3
(1, TIMESTAMP '2023-05-03 09:00:00', 1),
(1, TIMESTAMP '2023-05-03 13:00:00', 2),
(1, TIMESTAMP '2023-05-03 14:00:00', 1),
(1, TIMESTAMP '2023-05-03 18:00:00', 2),
-- Day 4
(1, TIMESTAMP '2023-05-04 09:00:00', 1),
(1, TIMESTAMP '2023-05-04 13:00:00', 2),
(1, TIMESTAMP '2023-05-04 14:00:00', 1),
(1, TIMESTAMP '2023-05-04 18:00:00', 2),
-- Day 5
(1, TIMESTAMP '2023-05-05 09:00:00', 1),
(1, TIMESTAMP '2023-05-05 13:00:00', 2),
(1, TIMESTAMP '2023-05-05 14:00:00', 1),
(1, TIMESTAMP '2023-05-05 18:00:00', 2),
-- Day 8
(1, TIMESTAMP '2023-05-08 09:00:00', 1),
(1, TIMESTAMP '2023-05-08 13:00:00', 2),
(1, TIMESTAMP '2023-05-08 14:00:00', 1),
(1, TIMESTAMP '2023-05-08 18:00:00', 2),
-- Day 9
(1, TIMESTAMP '2023-05-09 09:00:00', 1),
(1, TIMESTAMP '2023-05-09 13:00:00', 2),
(1, TIMESTAMP '2023-05-09 14:00:00', 1),
(1, TIMESTAMP '2023-05-09 18:00:00', 2),
-- Day 10
(1, TIMESTAMP '2023-05-10 09:00:00', 1),
(1, TIMESTAMP '2023-05-10 13:00:00', 2),
(1, TIMESTAMP '2023-05-10 14:00:00', 1),
(1, TIMESTAMP '2023-05-10 18:00:00', 2),
-- Day 11
(1, TIMESTAMP '2023-05-11 09:00:00', 1),
(1, TIMESTAMP '2023-05-11 13:00:00', 2),
(1, TIMESTAMP '2023-05-11 14:00:00', 1),
(1, TIMESTAMP '2023-05-11 18:00:00', 2),
-- Day 12
(1, TIMESTAMP '2023-05-12 09:00:00', 1),
(1, TIMESTAMP '2023-05-12 13:00:00', 2),
(1, TIMESTAMP '2023-05-12 14:00:00', 1),
(1, TIMESTAMP '2023-05-12 18:00:00', 2),
-- Day 15
(1, TIMESTAMP '2023-05-15 09:00:00', 1),
(1, TIMESTAMP '2023-05-15 13:00:00', 2),
(1, TIMESTAMP '2023-05-15 14:00:00', 1),
(1, TIMESTAMP '2023-05-15 18:00:00', 2),
-- Day 16
(1, TIMESTAMP '2023-05-16 09:00:00', 1),
(1, TIMESTAMP '2023-05-16 13:00:00', 2),
(1, TIMESTAMP '2023-05-16 14:00:00', 1),
(1, TIMESTAMP '2023-05-16 18:00:00', 2),
-- Day 17
(1, TIMESTAMP '2023-05-17 09:00:00', 1),
(1, TIMESTAMP '2023-05-17 13:00:00', 2),
(1, TIMESTAMP '2023-05-17 14:00:00', 1),
(1, TIMESTAMP '2023-05-17 18:00:00', 2),
-- Day 18
(1, TIMESTAMP '2023-05-18 09:00:00', 1),
(1, TIMESTAMP '2023-05-18 13:00:00', 2),
(1, TIMESTAMP '2023-05-18 14:00:00', 1),
(1, TIMESTAMP '2023-05-18 18:00:00', 2),
-- Day 19
(1, TIMESTAMP '2023-05-19 09:00:00', 1),
(1, TIMESTAMP '2023-05-19 13:00:00', 2),
(1, TIMESTAMP '2023-05-19 14:00:00', 1),
(1, TIMESTAMP '2023-05-19 18:00:00', 2),
-- Day 22
(1, TIMESTAMP '2023-05-22 09:00:00', 1),
(1, TIMESTAMP '2023-05-22 13:00:00', 2),
(1, TIMESTAMP '2023-05-22 14:00:00', 1),
(1, TIMESTAMP '2023-05-22 18:00:00', 2),
-- Day 23
(1, TIMESTAMP '2023-05-23 09:00:00', 1),
(1, TIMESTAMP '2023-05-23 13:00:00', 2),
(1, TIMESTAMP '2023-05-23 14:00:00', 1),
(1, TIMESTAMP '2023-05-23 18:00:00', 2),
-- Day 24
(1, TIMESTAMP '2023-05-24 09:00:00', 1),
(1, TIMESTAMP '2023-05-24 13:00:00', 2),
(1, TIMESTAMP '2023-05-24 14:00:00', 1),
(1, TIMESTAMP '2023-05-24 18:00:00', 2),
-- Day 25
(1, TIMESTAMP '2023-05-25 09:00:00', 1),
(1, TIMESTAMP '2023-05-25 13:00:00', 2),
(1, TIMESTAMP '2023-05-25 14:00:00', 1),
(1, TIMESTAMP '2023-05-25 18:00:00', 2),
-- Day 26
(1, TIMESTAMP '2023-05-26 09:00:00', 1),
(1, TIMESTAMP '2023-05-26 13:00:00', 2),
(1, TIMESTAMP '2023-05-26 14:00:00', 1),
(1, TIMESTAMP '2023-05-26 18:00:00', 2),
-- Day 29
(1, TIMESTAMP '2023-05-29 09:00:00', 1),
(1, TIMESTAMP '2023-05-29 13:00:00', 2),
(1, TIMESTAMP '2023-05-29 14:00:00', 1),
(1, TIMESTAMP '2023-05-29 18:00:00', 2),
-- Day 30
(1, TIMESTAMP '2023-05-30 09:00:00', 1),
(1, TIMESTAMP '2023-05-30 13:00:00', 2),
(1, TIMESTAMP '2023-05-30 14:00:00', 1),
(1, TIMESTAMP '2023-05-30 18:00:00', 2),
-- Day 31
(1, TIMESTAMP '2023-05-31 09:00:00', 1),
(1, TIMESTAMP '2023-05-31 13:00:00', 2),
(1, TIMESTAMP '2023-05-31 14:00:00', 1),
(1, TIMESTAMP '2023-05-31 18:00:00', 2);

select * from realtors;
select * from salary(5);

