WHENEVER SQLERROR EXIT FAILURE;
startup mount
--Select name, value from v$parameter where name like 'cluster_database%';
Exit;

