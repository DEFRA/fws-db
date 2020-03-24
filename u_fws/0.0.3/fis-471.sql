TRUNCATE TABLE u_fws.message;

ALTER SEQUENCE U_fws.message_id_seq nomaxvalue NORESTART;

ALTER TABLE u_fws.message DISABLE TRIGGER trg_message_update_latest;

-- TODO : 2 more SQL copy statements need to go here

ALTER TABLE u_fws.message ENABLE TRIGGER trg_message_update_latest;