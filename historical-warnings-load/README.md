# FWS-DB: Historical flood warning data load

In order to load historical flood warning data into the new Flood Warning Information System from the original service the process to be followed is outlined here.

It is strongly recommended to take a backup of the FWS database prior to performing the history load process for rollback purposes. Also, preparing queries to take record counts prior and post load is advisable.

1. Clone this repository then perform the following:

>
> `cd historical-warnings-load`
>
> `npm i`
>
> 

2. Copy the 'cleaned' csv file containing the historical flood warnings data to this directory and rename it to:

>
> `cleaned-transformed.csv`
>

NB: If the 'cleaned' csv file is unavailable then the process to create one is detailed [below](#create-cleaned-csv).

3. (Optional but advised). Run the following psql which performs a variety of queries producing database counts prior to history load:

>
> `psql <db connection string> -f ./pre-post-load-queries.sql > before-load.out`
>

4. Run the following psql command to copy the the historical data to the database:

>
> `psql <db connection string> -f ./import-and-process-historical-warnings.sql`
>

5. (Optional but advised). Run the following psql which performs a variety of queries producing database counts prior to history load:

>
> `psql <db connection string> -f ./pre-post-load-queries.sql > after-load.out`
>


The syntax of the db connection strings above should be:

>
> `postgres://`_`<user>:<password>`_`@`_`<hostname>`_`:5432/`_`<dbname>`_
>

If the copy is successful, the ouput to stdout should be something like:

```
psql <db connection string> -f ./import-and-process-historical-warnings.sql
CREATE FUNCTION
ALTER TABLE
COPY 114154
psql:./import-and-process-historical-warnings.sql:64: NOTICE:  5 Count - 1382
psql:./import-and-process-historical-warnings.sql:64: NOTICE:  Not 5 Count - 1117
>process_history
>-----------------
>(1 row)
>ALTER TABLE
```
The sql script executed above i.e. `./import-and-process-historical-warnings.sql` is described in detail [below](#import-script)

# <a name="create-cleaned-csv">Process to create 'cleaned' csv file of historal warnings data</a>

1. Request csv file containing a snapshot of the full historical warnings dataset from the business. The csv file should be in the format shown in the sample below:

> "TA_CODE","TA_ID","TA_NAME","SeverityValue","Severity","Approved","Situation","MESSAGEID"
>
>"063WAT23West","4a3597080ab71fc4182d10d7a3060215","Tidal Thames riverside from Putney Bridge to Teddington Weir","4","Warning no longer in force","2012-08-31 07:13:47","","7b4e304a0ab71fc41986a5d964a5b3bd"
>"031WAF104","b75852070a052604016408c104aee244","Tern and Perry Catchments","4","Warning no longer in force","2012-08-31 07:52:55","","7b71e4cf0ab71fc41986a5d9c86ab674"
>"122WAC953","9d84e2250ab7aa45016026bc8b7ea2d7","North Sea coast from Whitby to Filey","4","Warning no longer in force","2012-08-31 09:06:24","","7bb656230ab71fc5184fcef71bb96fb9"
>"051WACDV4C","373367ac0ab7aa44157933e224605385","The Essex coast from Clacton to and including, St Peters Flat and the Colne and Blackwater estuaries","1","Flood alert","2012-08-31 09:15:00","Migrated from >FWIS 4","7bb711d10ab71fc41986a5d917710ef1"
    
2. Manually remove embedded new lines (`\n`) and remove or replace redundant and isolated/unmatched double quotes in the "Situation" column. This can be achieved be performing a regex search and replace in a spreadsheet application (e.g. Excel, Libre Office Calc).

3. Clone this repository then perform the following:

>
> `cd historical-warnings-load`
>
> `npm i`
>
> 

4. Run the transform script `./fws-history-csv-transform.js`. Usage is:
>
> `node ./fws-history-csv-transform.js` _`<full path to file requested in step 1>`_
>

The script produces a file that can the be uploaded into to database. The name of this file is the same as the input file but suffixed with `-transformed.csv`.

# <a name="import-script">Description of historical data loading sql script - _import-and-process-historical-warnings.sql_</a>

This script bundles together the sql commands necessary to prepare the database for the insertion of historical data. There are essentially 5 parts to the script.

1. Define the `process_history` function. This function ensures the most recent historical warning for a target area is not treated as the current warning.

2. Disable the `update_latest` trigger (`trg_message_update_latest`). This trigger sets the 'latest' flag to true when inserting a record on the `u_fws.message` table. If the trigger is not disabled the execution time increase significantly.

3. Copy the 'cleaned' csv file to the database e.g.

>
> `\copy u_fws.message(target_area_code,severity,severity_value,situation,situation_changed,severity_changed,message_received,latest,created_by_id,created_by_email,created_by_name) FROM './cleaned-transformed.csv' DELIMITER ',' CSV HEADER;`
>

4. Execute the `process_history()` pgsql function defined earlier in step 1.

5. Enable the `update_latest` trigger (`trg_message_update_lates`).