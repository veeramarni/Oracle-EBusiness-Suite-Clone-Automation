VARIABLE arg_1 varchar2(200);
SET DEFINE ON
EXEC :arg_1 := '&1';
SET DEFINE OFF
DECLARE
stat boolean;
v_site_name varchar2(200);
BEGIN
dbms_output.disable;
dbms_output.enable(1000000);
v_site_name := :arg_1;
stat := FND_PROFILE.SAVE('SITENAME',v_site_name,'SITE');
IF stat THEN
dbms_output.put_line('Stat = TRUE - SITENAME profile updated');
ELSE
dbms_output.put_line('Stat= FALSE - SITENAME profile NOT updated');
END IF;
commit;
END;
/
