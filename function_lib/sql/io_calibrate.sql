spool /u01/app/oracle/scripts/refresh/logs/DSGN/DSGN_io_calibration.log
exec dbms_stats.delete_system_stats;
exec dbms_stats.gather_system_stats('EXADATA');
/
delete from resource_io_calibrate$;
commit;
SET SERVEROUTPUT ON
DECLARE
lat INTEGER;
iops INTEGER;
mbps INTEGER;
BEGIN
--DBMS_RESOURCE_MANAGER.CALIBRATE_IO(<NUM_DISKS>, <MAX_LATENCY>, iops, mbps, lat); 
DBMS_RESOURCE_MANAGER.CALIBRATE_IO (84, 10, iops, mbps, lat); 
DBMS_OUTPUT.PUT_LINE ('max_iops = ' || iops); DBMS_OUTPUT.PUT_LINE ('latency = ' || lat); 
dbms_output.put_line('max_mbps = ' || mbps); end;
/

delete from resource_io_calibrate$;
insert into resource_io_calibrate$ values(current_timestamp,current_timestamp, 0, 0, 200, 0, 0); 
commit;
spool off
exit;
