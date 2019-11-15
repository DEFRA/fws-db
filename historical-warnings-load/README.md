# FWS-DB: Historical flood warning data load

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
> `ALTER TABLE u_fws.message;`
> `DISABLE TRIGGER trg_message_update_latest`
>

7. Use the file created in step 3 as input to the COPY command. Run this command in the psql cli or pgadmin e.g.

>
> `\copy u_fws.message(target_area_code,severity,severity_value,situation,situation_changed,severity_changed,message_received,latest,created_by_id,created_by_email,created_by_name) FROM `_`'<full path to transformed file created in step 3>'`_ `DELIMITER ',' CSV HEADER;`
>

8. On successful completion of step 7 run the `process_history()` pgsql function in the psql cli or pgadmin which ensures the most recent historical warning for a target area is not treated as the current warning.

9. Enable the trigger on the `u_fws.message` table

>
> `ALTER TABLE u_fws.message;`
> `ENABLE TRIGGER trg_message_update_latest`
>

