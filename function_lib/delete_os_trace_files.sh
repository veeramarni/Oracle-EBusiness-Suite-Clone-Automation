delete_os_trace_files()
{
dbname=$1
ldbname=`echo "$dbname" | tr [A-Z] [a-z]`
#
orasid="$dbname"1
export ORACLE_SID="$orasid"
export ORACLE_HOME=/u01/app/oracle/product/11.2.0.4/dbhome_2
export NLS_DATE_FORMAT='DD-MM-RRRR HH24:MI:SS'
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_BASE=/u01/app/oracle
#
if [ $dbname == "DBM01" ]
then 
	orasid="$ldbname"1
	export ORACLE_SID="$orasid"
	export ORACLE_HOME=/u01/app/oracle/product/11.2.0.4/dbhome_1
	export NLS_DATE_FORMAT='DD-MM-RRRR HH24:MI:SS'
	export PATH=$ORACLE_HOME/bin:$PATH
	export ORACLE_BASE=/u01/app/oracle
fi
#
case $dbname in
	"DSGN")
		rm  /u01/app/oracle/diag/rdbms/dsgn/DSGN1/trace/DSGN*   \
			> /u01/app/oracle/scripts/refresh/logs/DSGN_delete_os_trace_files.log
		;;
	"DSTP")
		rm  /u01/app/oracle/diag/rdbms/dstp/DSTP1/trace/DSTP*   \
			> /u01/app/oracle/scripts/refresh/logs/DSTP_delete_os_trace_files.log
		;;
	"DBM01")
		rm /u01/app/oracle/diag/rdbms/dbm01/dbm011/trace/dbm01* \
			 > /u01/app/oracle/scripts/refresh/logs/DBM01_delete_os_trace_files.log 
		;;
	*)
		echo "wrong database to delete old OS trace files";;
esac
}		

