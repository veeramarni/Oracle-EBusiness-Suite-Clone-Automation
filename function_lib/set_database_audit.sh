set_database_audit()
{
orasid=$1
orahome=$2
dbname=$3
export ORACLE_SID=${orasid}
export ORACLE_HOME=${orahome}
export NLS_DATE_FORMAT='DD-MM-RRRR HH24:MI:SS'
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_BASE=/u01/app/oracle
case $dbname in
	"DSGN")
		"$ORACLE_HOME"/bin/sqlplus /" as sysdba"  \
			@${sqlbasepath}set_database_audit.sql \
			> ${logfilepath}${orasid}_set_database_audit.log
			;;
	*)
		echo "wrong database to delete old OS trace files"
		;;
esac
}