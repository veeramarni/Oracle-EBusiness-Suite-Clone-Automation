alter_database_archivelog_enable()
{
orasid=$1
orahome=$2
#
export ORACLE_SID=${orasid}
export ORACLE_HOME=${orahome}
export PATH=$ORACLE_HOME/bin:$
#
"$ORACLE_HOME"/bin/sqlplus /" as sysdba"    \
			@${sqlbasepath}alter_database_archivelog_enable.sql \
			> ${logfilepath}${dbname}_alter_database_archivelog_enable.log

}
