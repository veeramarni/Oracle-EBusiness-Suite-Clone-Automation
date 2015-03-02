check_database_status1()
{
orasid=$1
orahome=$2
export ORACLE_SID=${orasid}
export ORACLE_HOME=${orahome}

${ORACLE_HOME}/bin/sqlplus /" as sysdba" @${sqlbasepath}database_status1.sql \
	>${logfilepath}${orasid}_database_status1.log
}
