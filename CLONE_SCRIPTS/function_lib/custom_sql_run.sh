custom_sql_run()
{
orasid=$1
orahome=$2
sqlfile=$3
lgfile=$4
export ORACLE_SID=${orasid}
export ORACLE_HOME=${orahome}
"$ORACLE_HOME"/bin/sqlplus /" as sysdba"  \
			@${sqlfile} \
			> ${lgfile}
}