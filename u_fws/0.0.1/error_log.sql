-- Table: errorlog

-- DROP TABLE u_fws.errorlog;

CREATE TABLE u_fws.errorlog
(
  id bigserial NOT NULL,
  created timestamp with time zone,
  error_message character varying,
  fws_message character varying,
  CONSTRAINT errorlog_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE u_fws.errorlog
  OWNER TO u_fws;

