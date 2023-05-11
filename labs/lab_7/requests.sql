--- 1 -------------------------------------------------------------------
-- Написать процедуру, которая уменьшает стоимость объектов недвижимости.
-- Если объект недвижимости был добавлен более 6 месяцев назад и средняя
-- оценка ниже 6 баллов (из 10) на 5%
-- Если объект недвижимости был добавлен более 9 месяцев назад и средняя
-- оценка ниже 5 баллов (из 10) на 10%
-- Если объект недвижимости был добавлен более 12 месяцев назад и средняя
-- оценка ниже 4 баллов (из 10) на 20%
-------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE lab_7_ex_1()
LANGUAGE plpgsql
AS $$
DECLARE
    property_id INT;
    property_date TIMESTAMP;
    avg_rating NUMERIC;
    price NUMERIC;
BEGIN
    FOR property_id, property_date, avg_rating, price IN 
        SELECT o.id, o.date, AVG(r.rate), o.cost/o.square
        FROM objects o
        LEFT JOIN rates r ON o.id = r.object_id
        GROUP BY o.id
    LOOP
        IF property_date < (now() - INTERVAL '12 months') AND avg_rating < 4 THEN
            price := price * 0.8; -- decrease by 20%
        ELSIF property_date < (now() - INTERVAL '9 months') AND avg_rating < 5 THEN
            price := price * 0.9; -- decrease by 10%
        ELSIF property_date < (now() - INTERVAL '6 months') AND avg_rating < 6 THEN
            price := price * 0.95; -- decrease by 5%
        END IF;
        
        UPDATE objects SET cost = price * square WHERE id = property_id;
    END LOOP;
END;
$$;

SELECT id, cost FROM objects;

CALL lab_7_ex_1();
SELECT id, cost FROM objects ORDER BY id;

--- 2 -------------------------------------------------------------
-- Написать функцию, которая выводит информацию об объекте
-- недвижимости: стоимость 1м2, стоимость больше или меньше средней
-- стоимости однотипных объектов недвижимости в том же районе.
-------------------------------------------------------------------
CREATE OR REPLACE FUNCTION lab_7_ex_2(property_id INT)
RETURNS TABLE (
    sqm_price NUMERIC,
    price_vs_avg TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    property_price NUMERIC;
    property_district TEXT;
    avg_price NUMERIC;
BEGIN
    SELECT o.cost/o.square, d.name
	INTO property_price, property_district
    FROM objects o
    LEFT JOIN districts d ON o.district_id = d.id
    WHERE o.id = property_id;
    
    SELECT AVG(o2.cost/o2.square)
	INTO avg_price
    FROM objects o2
    WHERE o2.district_id = (SELECT district_id FROM objects WHERE id = property_id);
    
    sqm_price := property_price;
    
    IF property_price > avg_price THEN
        price_vs_avg := 'Больше средней';
    ELSE
        price_vs_avg := 'Меньше средней';
    END IF;
    
    RETURN NEXT;
END;
$$;

SELECT * FROM lab_7_ex_2(1);

--- 3 --------------------------------------------------------------------
-- Добавить таблицу «Динамика цен», где будет хранится изменения
-- стоимости. Таблица будет содержать следующие колонки: код объекта
-- недвижимости, новая стоимость, дата изменения. Создать триггер, который
-- при добавлении/изменении записи в таблице «Объекты недвижимости»,
-- добавляет новую запись в таблицу «Динамика цен»
--------------------------------------------------------------------------
CREATE TABLE price_history (
    object_id INT REFERENCES objects(id),
    new_price NUMERIC,
    date_changed TIMESTAMP
);

CREATE OR REPLACE FUNCTION lab_7_ex_3()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO price_history (object_id, new_price, date_changed)
        VALUES (NEW.id, NEW.cost/NEW.square, NOW());
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO price_history (object_id, new_price, date_changed)
        VALUES (NEW.id, NEW.cost/NEW.square, NOW());
    END IF;
    
    RETURN NEW;
END;
$$;

CREATE TRIGGER lab_7_ex_3
AFTER INSERT OR UPDATE ON objects
FOR EACH ROW
EXECUTE FUNCTION lab_7_ex_3();

INSERT INTO objects
(district_id, address, floor, rooms, type_id, status, cost, description, material_id, square, date) VALUES
(1, 'ул. Пушкина, д.10', 5, 3, 1, true, 200000, 'Просторная квартира в центре города', 2, 100, '2022-01-01');

SELECT * FROM price_history;

--- 4 ---------------------------------------------------------
-- Написать функцию, которая возвращает стоимость продажи в
-- текстовом формате. Пример, 1650000 –> один миллион шестьсот
-- пятьдесят тысяч руб.
---------------------------------------------------------------
CREATE OR REPLACE FUNCTION lab_7_ex_4(cost NUMERIC) 
RETURNS TEXT 
AS $$
DECLARE
   units CONSTANT TEXT[] := ARRAY['', 'один', 'два', 'три', 'четыре', 'пять', 'шесть', 'семь', 'восемь', 'девять'];
   tens_units CONSTANT TEXT[] := ARRAY['', 'одиннадцать', 'двенадцать', 'тринадцать', 'четырнадцать', 'пятнадцать', 'шестнадцать', 'семнадцать', 'восемнадцать', 'девятнадцать'];
   tens CONSTANT TEXT[] := ARRAY['', 'десять', 'двадцать', 'тридцать', 'сорок', 'пятьдесят', 'шестьдесят', 'семьдесят', 'восемьдесят', 'девяносто'];
   hundreds CONSTANT TEXT[] := ARRAY['', 'сто', 'двести', 'триста', 'четыреста', 'пятьсот', 'шестьсот', 'семьсот', 'восемьсот', 'девятьсот'];
   thousands_millions CONSTANT TEXT[] := ARRAY['', 'тысяч', 'миллион', 'миллиард', 'триллион', 'квадриллион', 'квинтиллион', 'секстиллион', 'септиллион', 'октиллион'];
   forms CONSTANT TEXT[][] := ARRAY[
      ARRAY['', '', ''],
      ARRAY['', 'а', 'ов'],
      ARRAY['', 'н', 'на'],
      ARRAY['', 'н', 'на']
   ];
   
   FUNCTION get_form(index INT, number INT) RETURNS TEXT AS $$
   BEGIN
      IF (number % 100 >= 11 AND number % 100 <= 19) THEN
         RETURN forms[index][3];
      ELSE
         RETURN forms[index][number % 10];
      END IF;
   END;
   
   FUNCTION convert_number(number INT, form_index INT) RETURNS TEXT AS $$
   DECLARE
      result TEXT := '';
   BEGIN
      IF (number >= 100) THEN
         result := result || hundreds[number / 100] || ' ';
         number := number % 100;
      END IF;
      
      IF (number >= 20) THEN
         result := result || tens[number / 10] || ' ';
         number := number % 10;
      ELSIF (number >= 11) THEN
         result := result || tens_units[number % 10] || ' ';
         number := 0;
      END IF;
      
      IF (number > 0) THEN
         result := result || units[number] || ' ';
      END IF;
      
      result := result || get_form(form_index, number);
      RETURN result;
   END;
   
   FUNCTION convert_group(number INT, form_index INT) RETURNS TEXT AS $$
   BEGIN
      IF (number = 0) THEN
         RETURN '';
      ELSE
         RETURN convert_number(number, form_index) || ' ';
      END IF;
   END;
   
   FUNCTION convert_to_text

