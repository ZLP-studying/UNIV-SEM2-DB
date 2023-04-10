--- 1 --------------------------------------------------------------------
-- Создать триггер, который меняет значение поля «Статус» в таблице
-- «Объекты недвижимости» на
-- 0 – при добавлении новой продажи и на 1 – при удалении записи о продаже
--------------------------------------------------------------------------


--- 2 ---------------------------------------------------------------------
-- Создать триггер, который будет выводить сообщение при разнице заявленной
-- и продажной стоимости объекта недвижимости более чем на 20%
---------------------------------------------------------------------------


--- 3 ------------------------------------------------------------------------
-- Создать триггер, который при добавлении новой продажи будет осуществлять
-- проверку статуса объекта недвижимости. Если в таблице «Продажи» уже имеется
-- запись о продаже данного объекта, выводить соответствующее сообщение.
------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION lab_5_ex3()
RETURNS TRIGGER AS
$$
BEGIN
IF NEW.object_id IN
(
	SELECT id
	FROM objects
	WHERE status = true
)
THEN RAISE EXCEPTION 'ERROR! Object has already been sold.';
END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER lab_5_ex3
BEFORE INSERT OR UPDATE
ON sales
FOR EACH ROW
EXECUTE FUNCTION lab_5_ex3();

INSERT INTO sales
(object_id, date, realtor_id, cost) VALUES
(3, '2019-10-10', 3, 19822000);

--- 4 -----------------------------------------------------------
-- Создать триггер, который при добавлении новой записи в таблицу
-- «Структура объекта недвижимости» проверяет несоответствие
-- заявленных комнат (в большую сторону) с общей площадью
-- объекта недвижимости
-- Выводить сообщение на сколько превышена площадь
-----------------------------------------------------------------
CREATE OR REPLACE FUNCTION lab_5_ex4()
RETURNS TRIGGER AS
$$
DECLARE delta integer;
BEGIN
delta = NEW.square +
(
	SELECT SUM(square)
	FROM structures
	WHERE object_id = NEW.object_id
) -
(
	SELECT square
	FROM objects
	WHERE id = NEW.object_id
);
IF delta > 0 THEN
RAISE EXCEPTION 'ERROR! The square is less on (%)', delta*(-1);
END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER lab_5_ex4
BEFORE INSERT OR UPDATE
ON structures
FOR EACH ROW
EXECUTE FUNCTION lab_5_ex4();

INSERT INTO structures VALUES
(2, 1, 37);

--- 5 --------------------------------------------------------------------------
-- Добавить таблицу «Бонусы», в которой будет две колонки: код риэлтора и размер
-- накопленных бонусов. Размер бонуса рассчитывается по формуле – стоимость
-- продажи*5%. Создать триггер, который будет автоматически увеличивать размер
-- накопленного бонуса при добавлении новой продажи. Необходимо учесть, что
-- продажа риэлтора может быть впервые и следовательно необходимо добавить новую
-- запись в таблицу. При удалении продажи, размер накопленного бонуса также
-- должен уменьшиться.
--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION lab_5_ex5()
RETURNS TRIGGER AS
$$
DECLARE add_bonus double precision;
BEGIN
IF NEW IS NOT NULL THEN
	add_bonus = NEW.cost * 0.05;
	IF NEW.realtor_id NOT IN
	(
		SELECT realtor_id
		FROM bonuses
	)
	THEN
		INSERT INTO bonuses
		(realtor_id, bonus) VALUES
		(NEW.realtor_id, add_bonus);
	ELSE
		UPDATE bonuses
			SET bonus = bonus + add_bonus
			WHERE realtor_id = NEW.realtor_id;
	END IF;
	RETURN NEW;
ELSE
	add_bonus = -OLD.cost * 0.05;
	IF OLD.realtor_id NOT IN
	(
		SELECT realtor_id
		FROM bonuses
	) THEN
		RAISE EXCEPTION 'ERROR! Realtor has not bonuses yet';
	ELSE
		UPDATE bonuses
			SET bonus = bonus + add_bonus
			WHERE realtor_id = OLD.realtor_id;
	END IF;
	RETURN OLD;
END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER lab_5_ex5
BEFORE INSERT OR UPDATE OR DELETE
ON sales
FOR EACH ROW
EXECUTE FUNCTION lab_5_ex5();

-- Создать запись о продаже
INSERT INTO sales
(object_id, date, realtor_id, cost) VALUES
(2, '2019-10-10', 3, 19822000);
SELECT * FROM bonuses;

-- Удалить запись о продаже
DELETE FROM sales
WHERE object_id = 2
AND date = '2019-10-10'
AND realtor_id = 3
AND cost = 19822000;
SELECT * FROM bonuses;