-- Column: u_fws.message.latest

-- ALTER TABLE u_fws.message DROP COLUMN latest;

ALTER TABLE u_fws.message
    ADD COLUMN latest boolean NOT NULL DEFAULT false;
