CREATE OR REPLACE FUNCTION process_history()
RETURNS VOID AS $$
DECLARE
    rec RECORD;
    query text;
    fiveCount float4 := 0;
    notFiveCount float4 := 0;

BEGIN

   query := 'select distinct on (target_area_code) * from u_fws.message order by target_area_code, message_received DESC';

   FOR rec IN EXECUTE query
        LOOP
        IF (rec.message_received < now() - INTERVAL '1 DAY' AND rec.severity_value = '5') THEN
            fiveCount := fiveCount + 1;
--            RAISE NOTICE '% - % - %', rec.message_received, rec.target_area_code, rec.severity_value;
        ELSE
             notFiveCount := notFiveCount + 1;
             INSERT INTO u_fws.message (
                 target_area_code,
                 severity,
                 severity_value,
                 situation,
                 situation_changed,
                 severity_changed,
                 message_received,
                 latest,
                 created_by_id,
                 created_by_email,
                 created_by_name
             ) VALUES (
                 rec.target_area_code,
                 'None',
                 '5',
                 null,
                 now(),
                 now(),
                 now(),
                 false,
                 null,
                 null,
                 'History Load'
             );
--             RAISE NOTICE 'NOT 5 - % - % - %', rec.message_received, rec.target_area_code, rec.severity_value;
        END IF;
   END LOOP;
   RAISE NOTICE '5 Count - %', fiveCount;
   RAISE NOTICE 'Not 5 Count - %', notFiveCount;
END;
$$ LANGUAGE plpgsql;
