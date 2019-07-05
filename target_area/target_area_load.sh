psql ${FWS_DB_CONNECTION} -c "DELETE FROM u_fws.target_area"

psql ${FWS_DB_CONNECTION} -c "\copy u_fws.target_area(ta_code, ta_name, ta_description, quick_dial, version, state, ta_category, owner_area, created_date, last_modified_date) from ./TA_Upload_20190529.csv with delimiter as ',' CSV HEADER"
