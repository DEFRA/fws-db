CREATE OR REPLACE FUNCTION u_fws.update_latest()
	RETURNS trigger AS
$BODY$
BEGIN
	-- Set new record as the latest
	NEW.latest = true;
	
	-- Clear out previous latest message
	UPDATE u_fws.message
	SET latest = false
	WHERE latest
	AND target_area_code = NEW.target_area_code;
	
	RETURN NEW;	
END;
$BODY$
LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION u_fws.update_latest()
OWNER TO u_fws;

CREATE TRIGGER trg_message_update_latest
	BEFORE INSERT
	ON u_fws.message
	FOR EACH ROW
	EXECUTE PROCEDURE u_fws.update_latest();


