WHENEVER SQLERROR EXIT FAILURE;
alter system set db_file_name_convert='&1','&2','&3','&4' scope=spfile;
alter system set pdb_file_name_convert='&3','&4' scope=spfile;
alter system set log_file_name_convert='&1','&2' scope=spfile;
exit