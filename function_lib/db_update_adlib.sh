db_update_adlib()
{
orasid=$1
orahome=$2
contextfile=$3
export ORACLE_SID=${orasid}
export ORACLE_HOME=${orahome}
export CONTEXT_NAME=${contextfile}
cd $ORACLE_HOME/appsutil/install/$CONTEXT_NAME
cd $ORACLE_HOME/appsutil/install/$CONTEXT_NAME
"$ORACLE_HOME"/bin/sqlplus /" as sysdba"  \
			@adupdlib.sql libext \
			> ${logfilepath}${orasid}_db_update_adlib.log
}