ALTER TABLE u_fws.message
ALTER COLUMN severity TYPE character varying(50);

Update u_fws.message
SET severity = 'Flood alert'
where severity_value = '1';

Update u_fws.message
SET severity = 'Flood warning'
where severity_value = '2';

Update u_fws.message
SET severity = 'Severe flood warning'
where severity_value = '3';

Update u_fws.message
SET severity = 'Warning no longer in force'
where severity_value = '4';

Update u_fws.message
SET severity = 'None'
where severity_value = '5';
