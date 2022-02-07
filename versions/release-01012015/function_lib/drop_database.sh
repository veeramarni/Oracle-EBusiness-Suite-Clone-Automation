drop_database()
{
orasid=$1
orahome=$2
export ORACLE_SID=${orasid}
export ORACLE_HOME=${orahome}
"$ORACLE_HOME"/bin/sqlplus /" as sysdba"  \
			@${sqlbasepath}drop_database.sql \
			> ${logfilepath}${orasid}_drop_database.log
}