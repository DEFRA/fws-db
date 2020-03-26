-- for psql
copy u_fws.message(target_area_code,severity,severity_value,situation,situation_changed,severity_changed,message_received,latest,created_by_id,created_by_email,created_by_name)
FROM '<full path to transformed file created in step 3>' DELIMITER ',' CSV HEADER;

-- TODO : check is pgadmin copy command needs to go in here or not