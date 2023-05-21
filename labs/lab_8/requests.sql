--ex1-------------------------------------------------------

ALTER TABLE realtors
ADD COLUMN late_arrivals 	interval DEFAULT (interal '0'),
ADD COLUMN overtime       interval DEFAULT (interval '0');

--ex2-------------------------------------------------------

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
--вход----------------------
(1,'2023-01-01,08:59:33',1),
(2,'2023-01-01,11:21:10',1),
(3,'2023-01-01,09:15:52',1),
(4,'2023-01-01,07:56:01',1),
(5,'2023-01-01,08:56:14',1),

--выход---------------------
(1,'2023-01-01,20:02:17',2),
(2,'2023-01-01,17:11:19',2),
(3,'2023-01-01,18:00:29',2),
(4,'2023-01-01,18:16:37',2),
(5,'2023-01-01,18:05:54',2),

--выход на обед-------------
(1,'2023-01-01,13:01:12',2),
(2,'2023-01-01,13:01:25',2),
(3,'2023-01-01,13:01:36',2),
(4,'2023-01-01,12:42:33',2),
(5,'2023-01-01,13:01:50',2),

--вход после обеда----------
(1,'2023-01-01,13:46:02',1),
(2,'2023-01-01,13:51:10',1),
(3,'2023-01-01,13:51:26',1),
(4,'2023-01-01,13:46:08',1),
(5,'2023-01-01,14:06:11',1),

--остальное-----------------
(1,'2023-01-01,16:30:44',2),
(4,'2023-01-01,16:30:56',2),
(5,'2023-01-01,16:31:08',2),
(1,'2023-01-01,16:35:01',1),
(4,'2023-01-01,16:35:26',1),
(5,'2023-01-01,16:35:13',1);

--ex2-------------------------------------------------------

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

--function_that_finds_bad_worker--------------------------------------

INSERT INTO weekdays
(realtor_id,action_time,action_type)
VALUES
/*
realtor_id = 2 - bad worker
realtor_id = 1 - good worker
*/
--вход----------------------
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

--выход---------------------
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

--выход на обед-------------
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

--вход после обеда----------
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
