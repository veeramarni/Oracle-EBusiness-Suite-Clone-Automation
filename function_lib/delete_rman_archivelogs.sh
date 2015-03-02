delete_rman_archivelogs()
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
		rman target / @/u01/app/oracle/scripts/refresh/targets/DSGN/DSGN_delete_rman_archivelogs.rcv \
		> /u01/app/oracle/scripts/refresh/logs/DSGN_delete_rman_archivelogs.log
		;;
	"DSTP")
		rman target / @/u01/app/oracle/scripts/refresh/targets/DSTP/DSTP_delete_rman_archivelogs.rcv \
		> /u01/app/oracle/scripts/refresh/logs/DSTP_delete_rman_archivelogs.log
		;;
	"DBM01")
		rman target / @/u01/app/oracle/scripts/refresh/targets/DBM01/DBM01_delete_rman_archivelogs.rcv \
		> /u01/app/oracle/scripts/refresh/logs/DBM01_delete_rman_archivelogs.log
		;;
	*)
		echo "wrong target database for RMAN delete archivelogs";;
esac
}		

