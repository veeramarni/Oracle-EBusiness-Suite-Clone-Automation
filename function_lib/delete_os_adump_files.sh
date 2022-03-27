delete_os_adump_files()
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
		rm /u01/app/oracle/admin/DSGN/adump/DSGN*   \
			 >${logfilepath}${orasid}_delete_os_adump_files.log
		;;
	"DSTP")
		rm /u01/app/oracle/admin/DSTP/adump/DSTP*   \
			 >${logfilepath}${orasid}_delete_os_adump_files.log
		;;
	"DBM01")
		rm /u01/app/oracle/admin/dbm01/adump/DBM01* \
			>${logfilepath}${orasid}_delete_os_adump_files.log
		;;
	*)
		echo "wrong database to delete old OS trace files"
		;;
esac
}		

