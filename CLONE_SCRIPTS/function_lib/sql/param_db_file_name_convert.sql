WHENEVER SQLERROR EXIT FAILURE;
alter system set db_file_name_convert='&1','&2' scope=spfile;
exit