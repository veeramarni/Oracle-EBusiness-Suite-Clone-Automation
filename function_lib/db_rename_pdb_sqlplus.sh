db_rename_pdb_sqlplus()
{
orasid=$1
orahome=$2
srcpdb=$3
trgpdb=$4
#
export ORACLE_SID=${orasid}
export ORACLE_HOME=${orahome}
export PATH=${ORACLE_HOME}/bin:$PATH
prd_desc_file=${ORACLE_HOME}/dbs/${srcpdb}_PDBDesc.xml
ebs_srcpdb=ebs_${srcpdb}
ebs_trgpdb=ebs_${trgpdb}
srcpdb_ebs_patch=${srcpdb}_ebs_patch
trgpdb_ebs_patch=${trgpdb}_ebs_patch
#
# &1=srcpdb
# &2=$trgpdb
# &3=$prd_desc_file
# &4=$ebs_srcpdb
# &5=$ebs_trgpdb
# &6=$srcpdb_ebs_patch
# &7=$trgpdb_ebs_patch
"$ORACLE_HOME"/bin/sqlplus /" as sysdba"    \
			@${sqlbasepath}rename_pdb.sql $srcpdb $trgpdb $prd_desc_file $ebs_srcpdb $ebs_trgpdb $srcpdb_ebs_patch $trgpdb_ebs_patch \
			> ${logfilepath}${orasid}_db_rename_pdb.log

}
