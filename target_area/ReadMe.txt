# FWIS Target area load

Whilst target areas are not being dynamically updated from FWS to FWIS there is a 3 monthly target area load in line with other services such as the FIS.

Current business contact is Andrew Twigg who will provide a csv of the target area data (of both warning and alert areas combined) in a format that can be imported by FWIS.

When the csv is received, open the document in gedit, and ensure that there are no strange non utf8 characters that are not recognised, if there are then return for cleansing.

Then check that the fields match the following and in the correct order:

"TA_CODE","TA_NAME","TA_DESC","QDIAL","TA_VERSION","state","category","AREA","TA_CREATE","TA_LASTMOD"

If not then refer to previous data file and return to business for correction of the data.

The file needs to be named target_areas.csv and stored in the directory /fws-db/target_area/

To test the data file we can load the data from our local environment into the fws-dev database before publishing to the repository.

(For script details view the jenkins job FWS_DEV_102_UPDATE_TARGET_AREAS)

execute the following:

`psql ${FWS_DB_CONNECTION} -f ./target_area_load.sql`

${FWS_DB_CONNECTION} being the database connection string for fws-dev.

We can then do a count on the table target_area where state = 'A' to see how many active target areas have been loaded, and check that this matches the records in the csv file.

Also execute the automated tests for both the FWIS api and app.

And do some checks of the front end and searches of target areas to ensure that all the data is correct and present.

Once this is all confirmed push the data up to the repository, and run the job FWS_DEV_102_UPDATE_TARGET_AREAS to reload the data to dev, but from the jenkins environments.

Then following this the appropriate environments can then be updated.
