select count(*) as "Total warnings" from u_fws.message;

select count(*) as "Total history warnings" from u_fws.message where created_by_name like '%History Load%';

select
    count(*) as "Total history warnings severity 5 added today"
--     target_area_code, message_received, situation_changed 
from 
    u_fws.message 
where 
    created_by_name like '%History Load%' and
    message_received > '2020-04-03'::date and
    message_received >= CURRENT_DATE and    
    message_received = situation_changed and
    message_received = severity_changed and
    severity_value = '5'
-- order by 
--     message_received desc limit 10
;

select (
    select count(*) as "Total history warnings" from u_fws.message where created_by_name like '%History Load%'
) - (
select
    count(*) as "Total history warnings severity 5 added today"
--     target_area_code, message_received, situation_changed 
from 
    u_fws.message 
where 
    created_by_name like '%History Load%' and
    message_received >= CURRENT_DATE and    
    message_received = situation_changed and
    message_received = severity_changed and
    severity_value = '5'
-- order by 
--     message_received desc limit 10
) as "Total number of history records input";

select count(*) as "All latest warnings" from u_fws.message where latest;

select count(*) as "All latest warnings grouped ", created_by_name from u_fws.message where latest group by created_by_name;

select count(*) as "All warnings grouped", created_by_name from u_fws.message group by created_by_name;

select count(*) as "All latest non FWS", created_by_name from u_fws.message where latest and created_by_name is not null group by created_by_name;

select count(*) as "All non FWS", created_by_name from u_fws.message where created_by_name is not null group by created_by_name;

select count(*) as "All latest FWS", created_by_name from u_fws.message where latest and created_by_name is null group by created_by_name;

select count(*) as "All FWS (incl latest)", created_by_name from u_fws.message where created_by_name is null group by created_by_name;

select count(*) as "All FWS grouped by severity", severity_value from u_fws.message where created_by_name is null group by severity_value order by severity_value asc;

select count(*) as "All non FWS grouped by severity", severity_value from u_fws.message where created_by_name is not null group by severity_value order by severity_value asc;

select count(*) as "All warnings grouped by severity", severity_value from u_fws.message group by severity_value order by severity_value asc;

select count(*) as "Non printable" FROM u_fws.message WHERE situation similar to '%[^\x00-\x7f]+%';

select count(*) as "Non printable in history" FROM u_fws.message WHERE situation similar to '%[^\x00-\x7f]+%' and created_by_name like '%History Load%';

select count(*) as "Warnings added with todays date", created_by_name from u_fws.message where message_received >= CURRENT_DATE group by created_by_name;
