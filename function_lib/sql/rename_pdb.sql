WHENEVER SQLERROR EXIT FAILURE;
-- &1=srcpdb
-- &2=$trgpdb
-- &3=$prd_desc_file
-- &4=$ebs_srcpdb
-- &5=$ebs_trgpdb
-- &6=$srcpdb_ebs_patch
-- &7=$trgpdb_ebs_patch
alter pluggable database &1 close;
alter pluggable database &1 unplug into &3;
drop pluggable database &1;
create pluggable database &2 using &3 NOCOPY SERVICE_NAME_CONVERT=(&4,&5,&6,&7);
alter pluggable database &2 open read write;
alter pluggable database all save state instances=all;
exit



WHENEVER SQLERROR EXIT FAILURE;
alter pluggable database $srcpdb close;
exit