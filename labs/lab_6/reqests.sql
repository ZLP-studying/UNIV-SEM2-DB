-- 1 -----------------------------------------------------------
-- Добавить в таблицу «Объекты недвижимости» колонку, которая 
-- будет хранить стоимость 1 м2. Создать триггер, который будет 
-- автоматически рассчитывать и записывать стоимость объекта 
-- недвижимости при добавлении новой записи (значение поля 
-- «Стоимость» не указывать).
----------------------------------------------------------------
ALTER TABLE objects 
ADD COLUMN cost_per_m2 double precision;

CREATE OR REPLACE FUNCTION lab_6_ex1()
RETURNS TRIGGER AS $$
BEGIN
	NEW.cost = NEW.square * NEW.cost_per_m2;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER lab_6_ex1
BEFORE INSERT OR UPDATE
ON objects
FOR EACH ROW
EXECUTE FUNCTION lab_6_ex1();

INSERT INTO objects
(square, cost_per_m2) VALUES
(2, 50);
SELECT id, cost, square, cost_per_m2
FROM objects
ORDER BY id DESC;

-- 2 -----------------------------------------------------------
-- В таблицу «Риэлторы» добавить колонку «Паспортные данные». 
-- Создать триггер, который будет проверять корректность 
-- паспортных данных по маске: ХХХХ УУУУУУ, 
-- где Х – серия паспорта, У – номер паспорта. 
-- Между серией и номером паспорта пробел. При несоответствии 
-- вводимой информации маске, выводить сообщение.
----------------------------------------------------------------
ALTER TABLE realtors
ADD COLUMN passport character varying(11);

CREATE OR REPLACE FUNCTION lab_6_ex_2()
RETURNS TRIGGER AS $$
BEGIN
	IF NEW.passport NOT LIKE '____ ______' THEN
		RAISE EXCEPTION 'ERROR! Invalid passport input.';
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER lab_6_ex_2
BEFORE INSERT OR UPDATE
ON realtors
FOR EACH ROW
EXECUTE FUNCTION lab_6_ex_2();

INSERT INTO realtors
(passport) VALUES
('1253 12122');

-- 3 -----------------------------------------------------------
-- Создать триггер, который при добавлении нового риэлтора 
-- формат телефона:79996667788 преобразует в: +7 (999) 666 77 88
----------------------------------------------------------------
ALTER TABLE realtors 
ALTER COLUMN contacts TYPE character varying(24);

CREATE OR REPLACE FUNCTION lab_6_ex_3()
RETURNS TRIGGER AS $$
BEGIN
	NEW.contacts = CONCAT(
		'+', substr(NEW.contacts, 1, 1),
		' (', substr(NEW.contacts, 2, 3), ') ',
		substr(NEW.contacts,5,3), ' ',
		substr(NEW.contacts,8,2), ' ',
		substr(NEW.contacts,10,2), ' ');
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER lab_6_ex_3
BEFORE INSERT OR UPDATE
ON realtors
FOR EACH ROW
EXECUTE FUNCTION lab_6_ex_3();

INSERT INTO realtors
(contacts) VALUES
(79992223311);

SELECT id, contacts
FROM realtors
ORDER BY id DESC;

-- 4 -----------------------------------------------------------
-- Создать триггер, который будет проверять соответствие 
-- добавляемой оценки определенному диапазону [0,X].
----------------------------------------------------------------
CREATE OR REPLACE FUNCTION lab_6_ex_4()
RETURNS TRIGGER AS $$
BEGIN
	IF NEW.rate < 0 OR NEW.rate > 5 THEN
		RAISE EXCEPTION 'ERROR! Invalid grade input (Must be in range [0, 5]).';
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER lab_6_ex_4
BEFORE INSERT OR UPDATE
ON rates
FOR EACH ROW
EXECUTE FUNCTION lab_6_ex_4();

INSERT INTO rates
(rate) VALUES
(6);

-- 5 -----------------------------------------------------------
-- Создать триггер, который при добавлении новой продажи, 
-- выводит сообщение, если хотя бы по одному критерию 
-- данный объект имеет оценку ниже Х.
----------------------------------------------------------------
CREATE OR REPLACE FUNCTION lab_6_ex_5()
RETURNS TRIGGER 
AS $$
DECLARE
lo_rate INTEGER;
BEGIN
	lo_rate = 2;
	IF NEW.object_id IN (SELECT object_id FROM rates WHERE lo_rate > rate) THEN
		RAISE EXCEPTION 'Object has rate low then 2'; 
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER lab_6_ex_5
BEFORE INSERT
ON sales
FOR EACH ROW
EXECUTE FUNCTION lab_6_ex_5();

select * from rates where object_id = 11;

INSERT INTO sales
(object_id, date, realtor_id, cost) VALUES
(11, '2022-01-01', 4, 20000000);
	

-- 6 -----------------------------------------------------------
-- Создать таблицу, которая следующие сведения: дата, время, 
-- операция (добавления, обновление, удаление данных),
-- пользователь (текущий пользовать в СУБД). Добавить триггер, 
-- который при изменении данных в таблице «Продажи», будет 
-- фиксировать такое события в таблице-журнале.
----------------------------------------------------------------
CREATE TABLE sales_log (
    id SERIAL PRIMARY KEY,
    event_date DATE NOT NULL,
    event_time TIME NOT NULL,
    operation TEXT NOT NULL,
    user_name TEXT NOT NULL
);

CREATE OR REPLACE FUNCTION lab_6_ex6()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        INSERT INTO sales_log (event_date, event_time, operation, user_name) 
        VALUES (current_date, current_time, 'DELETE', current_user);
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO sales_log (event_date, event_time, operation, user_name) 
        VALUES (current_date, current_time, 'UPDATE', current_user);
    ELSIF TG_OP = 'INSERT' THEN
        INSERT INTO sales_log (event_date, event_time, operation, user_name) 
        VALUES (current_date, current_time, 'INSERT', current_user);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER sales_log_trigger
AFTER INSERT OR UPDATE OR DELETE
ON sales
FOR EACH ROW
EXECUTE FUNCTION lab_6_ex6();

INSERT INTO sales
(object_id) VALUES
(2);

SELECT * FROM sales_log;

-- 7 -----------------------------------------------------------
-- Создать триггер, который при добавлении нового риэлтора будет 
-- проверять корректность фамилии, имени, отчество (наличие 
-- только букв, первая буква прописная). При несоответствии, 
-- выводить сообщение.
----------------------------------------------------------------
CREATE OR REPLACE FUNCTION lab_6_ex7()
RETURNS TRIGGER AS $$
DECLARE
    lo_fullname TEXT;
BEGIN
    lo_fullname := CONCAT_WS(' ', NEW.s_name, NEW.f_name, NEW.t_name);
    IF NOT (lo_fullname ~ '^[А-ЯЁ][а-яё]+ [А-ЯЁ][а-яё]+ [А-ЯЁ][а-яё]+$') THEN
        RAISE EXCEPTION 'ERROR! Invalid fullname input.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER lab_6_ex7
BEFORE INSERT
ON realtors
FOR EACH ROW
EXECUTE FUNCTION lab_6_ex7();

INSERT INTO realtors
(s_name, f_name, t_name) VALUES
('Nikitin', 'Oleg', 'Evgenievich');

INSERT INTO realtors
(s_name, f_name, t_name) VALUES
('Никитин', 'Олег', 'Евгеньевич');
