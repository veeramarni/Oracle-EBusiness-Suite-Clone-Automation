VARIABLE arg_1 varchar2(200);
SET DEFINE ON
EXEC :arg_1 := '&1';
SET DEFINE OFF
DECLARE
stat boolean;
v_color varchar2(20);
BEGIN
dbms_output.disable;
dbms_output.enable(1000000);
v_color := :arg_1;
stat := FND_PROFILE.SAVE('FND_COLOR_SCHEME',v_color,'SITE');
IF stat THEN
dbms_output.put_line('Stat = TRUE - FND_COLOR_SCHEME profile updated');
ELSE
dbms_output.put_line('Stat= FALSE - FND_COLOR_SCHEME profile NOT updated');
END IF;
commit;
END;
/
