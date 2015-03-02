start_target_rman_replication_from_backups()
{
orasid=$1
orahome=$2
dbname=$3
rmandir=$4
export NLS_DATE_FORMAT='DD-MM-RRRR HH24:MI:SS'
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_SID=${orasid}
export ORACLE_HOME=${orahome}
#
case $dbname in
	$dbname)
		rman @${rmanbasepath}rman_replication_from_backups.rcv ${dbname} ${rmandir} \
			>${logfilepath}${dbname}_rman_replication_from_backups.log
		;;
	*)
		echo "wrong database for replication";;
esac
}		

