purge_audit()
{
orasid=$1
orahome=$2
export ORACLE_SID=${orasid}
export ORACLE_HOME=${orahome}
export PATH=$ORACLE_HOME/bin:$PATH
"$ORACLE_HOME"/bin/sqlplus /" as sysdba"    \
			@${sqlbasepath}purge_audit.sql \
			> ${logfilepath}${orasid}_purge_audit.log
}
