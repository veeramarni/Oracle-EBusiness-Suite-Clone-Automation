WHENEVER SQLERROR EXIT FAILURE;

spool /u01/app/oracle/scripts/refresh/logs/crt_dblink.log

CREATE PUBLIC DATABASE LINK "DG4MSQL.WORLD"
 CONNECT TO REFBROWSE
 IDENTIFIED BY "refbrowse"
 USING 'DG4MSQL';
spool off
exit;
