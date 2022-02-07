param_db_file_name_convert()
{
orasid=$1
orahome=$2
param1=$3
param2=$4
export ORACLE_SID=${orasid}
export ORACLE_HOME=${orahome}
"$ORACLE_HOME"/bin/sqlplus /" as sysdba"  \
			@${sqlbasepath}param_db_file_name_convert.sql $param1 $param2 \
			> ${logfilepath}${orasid}_param_db_file_name_convert.log
}