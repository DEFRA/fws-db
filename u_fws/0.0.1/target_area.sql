-- Table: target_area

-- DROP TABLE target_area;

CREATE TABLE target_area
(
  ta_id serial NOT NULL,
  ta_code character varying(20) NOT NULL,
  ta_name character varying(200) NOT NULL,
  ta_description character varying(500) NOT NULL,
  quick_dial character varying(20) NOT NULL,
  version character varying(20) NOT NULL,
  state character varying(20) NOT NULL,
  ta_category character varying(20) NOT NULL,
  owner_area character varying(100),
  created_date timestamp with time zone NOT NULL,
  last_modified_date timestamp with time zone NOT NULL,
  CONSTRAINT target_area_pkey PRIMARY KEY (ta_id),
  CONSTRAINT target_area_ta_code_key UNIQUE (ta_code)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE target_area
  OWNER TO u_fws;

-- Index: target_area_ta_code

-- DROP INDEX target_area_ta_code;

CREATE INDEX target_area_ta_code
  ON target_area
  USING btree
  (ta_code COLLATE pg_catalog."default")
TABLESPACE fws_indexes;


