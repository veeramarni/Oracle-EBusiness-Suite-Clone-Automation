WHENEVER SQLERROR EXIT FAILURE;
alter session set current_schema=apps;
exec fnd_conc_clone.setup_clean;
exit;