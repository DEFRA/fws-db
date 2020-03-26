TRUNCATE TABLE u_fws.message;

ALTER SEQUENCE U_fws.message_id_seq nomaxvalue NORESTART;

ALTER TABLE u_fws.message DISABLE TRIGGER trg_message_update_latest;