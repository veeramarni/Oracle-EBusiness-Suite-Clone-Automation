spool /u01/app/oracle/scripts/refresh/logs/audit_settings.log
noaudit CREATE SESSION;
noaudit CREATE USER;
noaudit ALTER USER;
noaudit DROP USER ;
noaudit role;
noaudit directory;
noaudit AUDIT SYSTEM;
noaudit ALTER ANY TABLE;
noaudit CREATE ANY PROCEDURE;
noaudit ALTER ANY PROCEDURE;
noaudit CREATE ANY TABLE;
noaudit ALTER ANY TABLE;
noaudit execute procedure by DBSNMP;
BEGIN 
FOR R IN (SELECT username FROM dba_users WHERE username NOT IN ('SYS','SYSTEM','GTSYS','FSV','WDCSVC','RMAN','DBSNMP')) 
LOOP 
EXECUTE IMMEDIATE 'audit all, select table, update table, insert table, delete table, execute procedure by '||'"'||R.USERNAME||'"'||' by access'; 
END LOOP; 
END; 
/

--to create audit user and enable auditing agent, uncomment the following
--alter user avcollector identified by "xxxxxx";
--@/u01/app/oracle/product/avagent/av/plugins/com.oracle.av.plugin.oracle/config/oracle_user_setup.sql avcollector setup
spool off
exit;
