# FWS-DB: Historical flood warning data load

## Table of Contents
- [Initial Historical Data Load](#initial-historical-data-load)
- [Historical flood warning second data upload (December 2025)](#fws-db-historical-flood-warning-second-data-upload-december-2025)
  - [Data Preperation](#data-preperation)
  - [Manual Historic Data Import Process (Updated 09/12/25)](#manual-historic-data-import-process-updated-091225)
    - [Step 1: Backup Database](#step-1-backup-database)
    - [Step 2: Get Initial Row Count](#step-2-get-initial-row-count)
    - [Step 3: Disable the update_latest Trigger](#step-3-disable-the-update_latest-trigger)
    - [Step 4: Import Data](#step-4-import-data)
    - [Step 5: Update the latest flag](#step-5-update-the-latest-flag)
    - [Step 6: Re-enable the update_latest Trigger](#step-6-re-enable-the-update_latest-trigger)
    - [Step 9: Get Final Row Count](#step-9-get-final-row-count)
    - [Troubleshooting](#troubleshooting)

## Initial Historical Data Load

In order to load historical flood warning data into the new Flood Warning Information System from the original service the process outlined below should be undertaken.

1. Request csv file containing a snapshot of the full historical warnings dataset from the business. A sample of the csv file used in in the intial load has the folloing format:

> "TA_CODE","TA_ID","TA_NAME","SeverityValue","Severity","Approved","Situation","MESSAGEID"
>
>"063WAT23West","4a3597080ab71fc4182d10d7a3060215","Tidal Thames riverside from Putney Bridge to Teddington Weir","4","Warning no longer in force","2012-08-31 07:13:47","","7b4e304a0ab71fc41986a5d964a5b3bd"
>"031WAF104","b75852070a052604016408c104aee244","Tern and Perry Catchments","4","Warning no longer in force","2012-08-31 07:52:55","","7b71e4cf0ab71fc41986a5d9c86ab674"
>"122WAC953","9d84e2250ab7aa45016026bc8b7ea2d7","North Sea coast from Whitby to Filey","4","Warning no longer in force","2012-08-31 09:06:24","","7bb656230ab71fc5184fcef71bb96fb9"
>"051WACDV4C","373367ac0ab7aa44157933e224605385","The Essex coast from Clacton to and including, St Peters Flat and the Colne and Blackwater estuaries","1","Flood alert","2012-08-31 09:15:00","Migrated from >FWIS 4","7bb711d10ab71fc41986a5d917710ef1"
    
2. Manually remove embedded new lines (`\n`) in the "Situation" column. This can be achieved be performing a regex search and replace in a spreadsheet application (e.g. Excel, Libre Office Calc).

3. Clone this repository then perform the following:

>
> `cd historical-warnings-load`
>
> `npm i`
>

3. Run the transform script `./fws-history-csv-transform.js`. Usage is:
>
> `node ./fws-history-csv-transform.js` _`<full path to file requested in step 1>`_
>

The script produces a file that can the be uploaded into to database. The name of this file is the same as the input file but suffixed with `-transformed.csv`

## NB: Only perform steps 4 & 5 if wanting to load history WITHOUT preserving warning messages that already exist in the u_fws.message table. Otherwise, proceed to step 6.

4. In the FWS database clear down the `u_fws.message` table

>
> `TRUNCATE TABLE u_fws.message;`
>

5. Restart the sequence

>
> `ALTER SEQUENCE U_fws.message_id_seq RESTART;`
>

6. Disable the trigger on the `u_fws.message` table

>
> `ALTER TABLE u_fws.message DISABLE TRIGGER trg_message_update_latest`
>

7. Use the file created in step 3 as input to the COPY command. Run this command in the psql cli or pgadmin e.g.

> for psql:
>
> `\copy u_fws.message(target_area_code,severity,severity_value,situation,situation_changed,severity_changed,message_received,latest,created_by_id,created_by_email,created_by_name) FROM `_`'<full path to transformed file created in step 3>'`_ `DELIMITER ',' CSV HEADER;`
>

> for pgadmin:
>
> `COPY u_fws.message(target_area_code,severity,severity_value,situation,situation_changed,severity_changed,message_received,latest,created_by_id,created_by_email,created_by_name) FROM `_`'<full path to transformed file created in step 3>'`_ `DELIMITER ',' CSV HEADER;`
>

8. On successful completion of step 7 run the `process_history()` pgsql function in the psql cli or pgadmin which ensures the most recent historical warning for a target area is not treated as the current warning.

9. Enable the trigger on the `u_fws.message` table

>
> `ALTER TABLE u_fws.message ENABLE TRIGGER trg_message_update_latest;`
>

# FWS-DB: Historical flood warning second data upload (December 2025)
Area teams have requested the message history from FWIS1 to be available in FWIS2, so they can view complete history in the FWIS2 app.

WebOps have exported the FWIS1 data, this can be seen on Jira ticket NI-122 https://eaflood.atlassian.net/browse/NI-122 

## Data Preperation

Some adjustments to the exported data have been made, these are:
  (1) Removing the ID column as this ID is set in the destination table.
  (2) Removing any target areas where there is no corresponding target area in the destination database (to avoid FK constraint errors).
  (3) Adding one additional row to the input csv file relating to target area 065waf123 which has been added with a ‘severity’ of 'none’ and a with timestamps date greater than the other timestamps for that target_area. That is to prevent it being active when imported.
  (4) Updating all rows to default the ‘latest’ (bool) to ‘f' to baseline them, and so they don't get any spurious 5 (all clear) records created by fwis front end during data load duration.

## Manual Historic Data Import Process (Updated 09/12/25)

The following steps document the manual steps to import historic data into the FWS PostgreSQL database.


### Step 1: Backup Database

Take a backup of the database as a precaution before starting the import process.

**Wait for backup to complete before proceeding.**


### Step 2: Get Initial Row Count

Get row count from `u_fws.message` table in PgAdmin.
  
  'SELECT COUNT(*) FROM u_fws.message;'

  Rowcount before import = ???


### Step 3: Disable the update_latest Trigger

Disable the `update_latest` trigger before import.

Run this query in PgAdmin:

  ALTER TABLE u_fws.message DISABLE TRIGGER trg_message_update_latest;


### Step 4: Import Data

**Before running the import add the {password} into the script, ensure the input_file_final.csv is placed in `/tmp/historic_data_upload/` on the server where the terminal command will be executed.**

Import the CSV file using the COPY command from bash terminal:
Please note this can take several minutes to complete.

PGPASSWORD={add password here} psql -h {add prod url here} -p 5432 -U u_fws -d {add prod db name here} << 'EOF'
BEGIN;
SET lock_timeout = '240s';
\COPY u_fws.message (target_area_code, severity, severity_value, situation, situation_changed, severity_changed, message_received, latest, created_by_id, created_by_email, created_by_name) FROM '/tmp/historic_data_upload/input_file_final.csv' WITH (FORMAT csv, HEADER true, NULL '', QUOTE '"')
COMMIT;
EOF

Note: If the above command works you should see this returned in the terminal
'COPY 263566
 COMMIT'


### Step 5: Update the latest flag

Run this query in PgAdmin to set the 'latest' flag correctly:

  -- First set all to false
  UPDATE u_fws.message
  SET latest = false;

  -- Then set to true for the newest message_received per target_area_code
  UPDATE u_fws.message m
  SET latest = true
  WHERE m.id IN (
      SELECT DISTINCT ON (target_area_code) id
      FROM u_fws.message
      ORDER BY target_area_code, message_received DESC
  );


### Step 6: Re-enable the update_latest Trigger

Re-enable the `update_latest` trigger after import.

Run this query in PgAdmin:

  ALTER TABLE u_fws.message ENABLE TRIGGER trg_message_update_latest;



### Step 9: Get Final Row Count

Get row count from `u_fws.message` table in PgAdmin.

  SELECT COUNT(*) FROM u_fws.message;

Final record count = ???


### Troubleshooting

#### If Import Fails with Deadlock
The import command includes a lock timeout of 240 seconds. If you encounter deadlocks:
1. Wait a few seconds
2. Retry the import command from Step 4
