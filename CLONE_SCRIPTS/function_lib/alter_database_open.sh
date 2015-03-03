alter_database_open()
{
orasid=$1
orahome=$2
export ORACLE_SID=${orasid}
export ORACLE_HOME=${orahome}
"$ORACLE_HOME"/bin/sqlplus /" as sysdba"  \
			@${sqlbasepath}alter_database_open.sql \
			> ${logfilepath}${dbname}_alter_database_open.log
}
