-- FWS database setup

CREATE TABLESPACE fws_tables OWNER u_fws LOCATION '/fws_tables';
CREATE TABLESPACE fws_indexes OWNER u_fws LOCATION '/fws_indexes';

CREATE SCHEMA u_fws AUTHORIZATION u_fws;