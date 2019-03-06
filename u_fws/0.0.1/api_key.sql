-- Table: u_fws.api_key

-- DROP TABLE u_fws.api_key;

CREATE TABLE u_fws.api_key
(
    api_key_id serial NOT NULL,
    account_id text COLLATE pg_catalog."default" NOT NULL,
    key text COLLATE pg_catalog."default" NOT NULL,
    account_name text COLLATE pg_catalog."default" NOT NULL,
    read boolean,
    write boolean,
    date_created date,
    date_modified date,
    modified_by text COLLATE pg_catalog."default",
    CONSTRAINT api_key_pkey PRIMARY KEY (api_key_id)
)
WITH (
    OIDS = FALSE
)
TABLESPACE fws_tables;

ALTER TABLE u_fws.api_key
    OWNER to u_fws;
