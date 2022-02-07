WHENEVER SQLERROR EXIT FAILURE;
SET Linesize 525
column HOST_NAME format a25
column INSTANCE format a09
column Last_Prod_JobStream format a22
column STARTUP_TIME format a22
column status format a10
  
SELECT HOST_NAME,INSTANCE_NAME AS INSTANCE , (SELECT to_char(MAX (fdtmwhen), 'DD-Mon-YYYY HH24:MI:SS')
        FROM gtapp.tbljobstream
        WHERE  fstrenvironment = 'GAP' )
        AS Last_Prod_JobStream, to_char(STARTUP_TIME, 'DD-Mon-YYYY HH24:MI:SS') AS Startup_TIME , STATUS
FROM   sys.gv_$instance;
Exit;

