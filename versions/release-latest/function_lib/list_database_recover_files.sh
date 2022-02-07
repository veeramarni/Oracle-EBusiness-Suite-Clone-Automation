list_database_recover_files()
{
orasid=$1
orahome=$2
export NLS_DATE_FORMAT='DD-MM-RRRR HH24:MI:SS'
export ORACLE_SID=${orasid}
export ORACLE_HOME=${orahome}
export PATH=$ORACLE_HOME/bin:$PATH
"$ORACLE_HOME"/bin/sqlplus /" as sysdba" \
		@${sqlbasepath}list_database_recover_files.sql \
		> ${logfilepath}${dbname}_list_database_recover_files.log
}
