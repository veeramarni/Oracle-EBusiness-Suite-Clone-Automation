purge_audit()
{
orasid=$1
orahome=$2
export ORACLE_SID=${orasid}
export ORACLE_HOME=${orahome}
export PATH=$ORACLE_HOME/bin:$PATH
"$ORACLE_HOME"/bin/sqlplus /" as sysdba" @/u01/app/oracle/scripts/refresh/targets/"$dbname"/"$dbname"_purge_audit.sql
}
