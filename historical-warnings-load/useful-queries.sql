select count(*) from u_fws.message;

select count(*) from u_fws.message where created_by_name like '%History Load%';

select count(*) from (select distinct on (target_area_code) * from u_fws.message where created_by_name like '%History Load%'and severity_value != '5' order by target_area_code, message_received) as result;

select count(*), target_area_code, created_by_name from u_fws.message where created_by_name like '%History Load%' group by (target_area_code, created_by_name) order by target_area_code asc;

select count(*) from u_fws.message where created_by_name like '%History Load%' and severity_value = '5';

select target_area_code, created_by_name from u_fws.message where created_by_name like '%History Load%' and severity_value != '5' group by target_area_code, created_by_name order by target_area_code asc;