CREATE TABLE player (
	player_id SERIAL PRIMARY KEY,
	name VARCHAR(100)
);

CREATE TABLE player_audits (
	player_audit_id SERIAL PRIMARY KEY,
	player_id INT NOT NULL,
	name VARCHAR(100) NOT NULL,
	edit_date TIMESTAMP NOT NULL
);

INSERT INTO player (name) VALUES 
('John'), 
('Lily');

-- create trigger
CREATE OR REPLACE FUNCTION fn_players_name_change_log()
	RETURNS TRIGGER 
	LANGUAGE PLPGSQL
AS $$
BEGIN
	
	IF NEW.name <> OLD.name THEN
		INSERT INTO player_audits(player_id, name, edit_date)
		VALUES(OLD.player_id, OLD.name, now());
	END IF;

	RETURN NEW;

END;
$$;

CREATE TRIGGER trg_players_name_change
	BEFORE UPDATE 
	ON player
	FOR EACH ROW
	EXECUTE PROCEDURE fn_players_name_change_log();
	
UPDATE player
SET name = 'Due'
WHERE player_id = 2;

-- disallow delete
CREATE OR REPLACE FUNCTION fn_disallow_delete()
	RETURNS TRIGGER	
	LANGUAGE PLPGSQL
AS $$

BEGIN

	IF TG_WHEN = 'AFTER' THEN

		RAISE EXCEPTION 'YOU ARE NOT ALLOWED TO % ROWS IN %.%', TG_OP, TG_TABLE_SCHEMA, TG_TABLE_NAME;

	END IF;

	RAISE NOTICE '% ON ROWS IN %.% WONT HAPPEN', TG_OP, TG_TABLE_SCHEMA, TG_TABLE_NAME;
	
	RETURN NULL;
END;

$$;

CREATE TRIGGER trg_disallow_delete_after
AFTER DELETE 
ON player
FOR EACH ROW 
EXECUTE PROCEDURE fn_disallow_delete();
	
CREATE TRIGGER trg_disallow_delete_before
BEFORE DELETE 
ON player
FOR EACH ROW 
EXECUTE PROCEDURE fn_disallow_delete();

DELETE FROM player WHERE player_id = 1;

-- disallow truncate
CREATE TRIGGER trg_disallow_truncate_after
AFTER TRUNCATE
ON player
FOR EACH STATEMENT 
EXECUTE PROCEDURE fn_disallow_delete();

CREATE TRIGGER trg_disallow_truncate_before
BEFORE TRUNCATE
ON player
FOR EACH STATEMENT
EXECUTE PROCEDURE fn_disallow_delete();

TRUNCATE player;

-- create audit trigger
CREATE TABLE audit(
	id INT
);

CREATE TABLE audit_log(
	username TEXT,
	add_time TIMESTAMP,
	table_name TEXT,
	operation TEXT,
	row_before JSON,
	row_after JSON
);

CREATE OR REPLACE FUNCTION fn_audit_trigger()
	RETURNS TRIGGER 
	LANGUAGE PLPGSQL
AS $$
	DECLARE
		old_row JSON := NULL;
		new_row JSON := NULL;	

	BEGIN
		
		-- TG_OP

		-- UPDATE, DELETE
			-- old_row
		IF TG_OP IN ('UPDATE', 'DELETE') THEN
			old_row := row_to_json(OLD);
		END IF;		

		-- INSERT, UPDATE
			-- new_row
		IF TG_OP IN ('INSERT', 'UPDATE') THEN
			new_row := row_to_json(NEW);
		END IF;

		-- INSERT aduit_log
		INSERT INTO audit_log
		(
			username,
			add_time,
			table_name,
			operation,
			row_before,
			row_after
		)
		VALUES
		(
			session_user,
			CURRENT_TIMESTAMP AT TIME ZONE 'UTC',
			TG_TABLE_SCHEMA || '.' || TG_TABLE_NAME,
			TG_OP,
			old_row,
			new_row
		);		

		RETURN NEW;
	END;
$$;

CREATE TRIGGER trg_audit_trigger
AFTER INSERT OR UPDATE OR DELETE 
ON audit
FOR EACH ROW 
EXECUTE PROCEDURE fn_audit_trigger();

INSERT INTO audit(id) VALUES (1); 
INSERT INTO audit(id) VALUES (2); 

UPDATE audit
SET id = 3
WHERE id = 1;

-- condition trigger
CREATE TABLE mytask (
	task_id SERIAL PRIMARY KEY,
	task TEXT
);

CREATE OR REPLACE FUNCTION fn_cancel_with_message()
	RETURNS TRIGGER 
	LANGUAGE PLPGSQL
AS $$
	DECLARE
	BEGIN
		RAISE EXCEPTION '%', TG_ARGV[0];
		RETURN NULL;
	END;
$$;

CREATE TRIGGER trg_no_update_on_friday_afternoon
BEFORE INSERT OR UPDATE OR DELETE OR TRUNCATE 
ON mytask
FOR EACH STATEMENT 
WHEN
(
	EXTRACT('DOW' FROM CURRENT_TIMESTAMP) = 5
	AND CURRENT_TIME > '12:00'
)
EXECUTE PROCEDURE fn_cancel_with_message('No update are allow at Friday Afternoon, so chil!!!');

INSERT INTO mytask(task)
VALUES('Go shopping');

-- disallow data change on primary key
CREATE OR REPLACE FUNCTION fn_disallow_change_data_primary_key()
	RETURNS TRIGGER	
	LANGUAGE PLPGSQL
AS $$
BEGIN
	IF TG_WHEN = 'AFTER' THEN
		RAISE EXCEPTION 'YOU ARE NOT ALLOWED TO % ROWS IN %.%', TG_OP, TG_TABLE_SCHEMA, TG_TABLE_NAME;
	END IF;

	RAISE NOTICE '% ON ROWS IN %.% WONT HAPPEN', TG_OP, TG_TABLE_SCHEMA, TG_TABLE_NAME;
	RETURN NULL;
END;
$$;

CREATE TRIGGER trg_disallow_change_data_primary_key_after
AFTER UPDATE OF task_id
ON mytask
FOR EACH ROW
EXECUTE PROCEDURE fn_disallow_change_data_primary_key();

CREATE TRIGGER trg_disallow_change_data_primary_key_before
BEFORE UPDATE OF task_id
ON mytask
FOR EACH ROW
EXECUTE PROCEDURE fn_disallow_change_data_primary_key();

UPDATE mytask
SET task_id = 1
WHERE task_id = 2;

-- create event trigger
CREATE TABLE audit_ddl (
	audit_ddl_id SERIAL PRIMARY KEY,
	username TEXT,
	ddl_event TEXT,
	ddl_command TEXT,
	ddl_add_time TIMESTAMPTZ
);

CREATE OR REPLACE FUNCTION fn_event_audit_ddl()
	RETURNS EVENT_TRIGGER
	LANGUAGE PLPGSQL
	SECURITY DEFINER
AS $$
	BEGIN
		-- insert
		INSERT INTO audit_ddl
		(
			username,
			ddl_event,
			ddl_command,
			ddl_add_time
		)
		VALUES
		(
			session_user,
			TG_EVENT,
			TG_TAG,
			NOW()
		);
		-- raise notice
		RAISE NOTICE 'DDL activity is added!';

	END;
$$;

CREATE EVENT TRIGGER trg_event_audit_ddl
ON ddl_command_start
EXECUTE PROCEDURE fn_event_audit_ddl();

CREATE EVENT TRIGGER trg_event_audit_ddl
ON ddl_command_start
WHEN
	TAG IN ('CREATE TABLE')
EXECUTE PROCEDURE fn_event_audit_ddl();

-- disable allow create table from 9am to 4pm
CREATE OR REPLACE FUNCTION fn_event_abort_create_table_function()
	RETURNS EVENT_TRIGGER
	LANGUAGE PLPGSQL
	SECURITY DEFINER
AS $$
	DECLARE
		current_hour INTEGER = EXTRACT('hour' FROM NOW());
	BEGIN
		IF current_hour BETWEEN 9 AND 16 THEN
			RAISE EXCEPTION 'Tables are not allowed to be created during 9am-4pm.';
		END IF;		
	END;
$$;

CREATE EVENT TRIGGER trg_event_abort_create_table_function
ON ddl_command_start
EXECUTE PROCEDURE fn_event_abort_create_table_function();
