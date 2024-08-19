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







































