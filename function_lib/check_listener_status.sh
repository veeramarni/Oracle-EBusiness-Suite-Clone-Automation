check_listener_status()
{
orasid=$1
orahome=$2
export ORACLE_SID=${orasid}
export ORACLE_HOME=${orahome}

${ORACLE_HOME}/bin/lsnrctl  \
	>${logfilepath}${orasid}_listener_status.log
}