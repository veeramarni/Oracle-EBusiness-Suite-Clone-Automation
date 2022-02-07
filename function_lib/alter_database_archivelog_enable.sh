alter_database_archivelog_enable()
{
orasid=$1
orahome=$2
#
export ORACLE_SID=${orasid}
export ORACLE_HOME=${orahome}
export PATH=$ORACLE_HOME/bin:$PATH
#
"$ORACLE_HOME"/bin/sqlplus /" as sysdba"    \
			@${sqlbasepath}alter_database_archivelog_enable.sql \
			> ${logfilepath}${orasid}_alter_database_archivelog_enable.log

}
