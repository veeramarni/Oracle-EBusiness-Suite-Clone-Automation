create_spfile()
{
orasid=$1
orahome=$2
#
export ORACLE_SID=${orasid}
export ORACLE_HOME=${orahome}
export PATH=$ORACLE_HOME/bin:$PATH
#
"$ORACLE_HOME"/bin/sqlplus /" as sysdba"    \
			@${sqlbasepath}create_spfile.sql \
			> ${logfilepath}${orasid}_create_spfile.log

}
