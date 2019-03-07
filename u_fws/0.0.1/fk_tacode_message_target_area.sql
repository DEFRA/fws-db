-- Constraint: ta_code_fk

-- ALTER TABLE u_fws.message DROP CONSTRAINT ta_code_fk;

ALTER TABLE u_fws.message
    ADD CONSTRAINT fk_tacode_message_target_area FOREIGN KEY (target_area_code)
    REFERENCES u_fws.target_area (ta_code) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;
