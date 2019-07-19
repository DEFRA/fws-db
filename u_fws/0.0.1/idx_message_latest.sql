-- Index: idx_message_latest

-- DROP INDEX u_fws.idx_message_latest;

CREATE INDEX idx_message_latest
    ON u_fws.message USING btree
    (latest)
    TABLESPACE fws_indexes;

