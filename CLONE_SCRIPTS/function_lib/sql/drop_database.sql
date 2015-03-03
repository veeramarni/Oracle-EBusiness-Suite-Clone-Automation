WHENEVER SQLERROR EXIT FAILURE;
alter system enable restricted session;
select name from v$database;
Drop database;
exit