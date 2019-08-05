-- Create temp table

CREATE TEMP TABLE tmp_target_area as Select * from u_fws.target_area LIMIT 0;

-- Load new data to temp table

\copy tmp_target_area(ta_code, ta_name, ta_description, quick_dial, version, state, ta_category, owner_area, created_date, last_modified_date) from /home/tedd/fws-db/target_area/target_areas.csv with delimiter as ',' CSV HEADER;

-- Update all target_area to inactive

UPDATE u_fws.target_area set state = 'inactive';

-- Do upsert for data

INSERT INTO
u_fws.target_area (ta_code, ta_name, ta_description, quick_dial, version, state, ta_category, owner_area, created_date, last_modified_date)
SELECT ta_code, ta_name, ta_description, quick_dial, version, state, ta_category, owner_area, created_date, last_modified_date
FROM tmp_target_area
ON CONFLICT (ta_code) 
DO UPDATE SET
ta_name = EXCLUDED.ta_name, 
ta_description = EXCLUDED.ta_description, 
quick_dial = EXCLUDED.quick_dial, 
version = EXCLUDED.version, 
state = EXCLUDED.state, 
ta_category = EXCLUDED.ta_category, 
owner_area = EXCLUDED.owner_area, 
created_date = EXCLUDED.created_date, 
last_modified_date = EXCLUDED.last_modified_date;

-- Drop temp table

DROP TABLE tmp_target_area
