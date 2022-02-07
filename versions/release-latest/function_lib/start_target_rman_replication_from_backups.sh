start_target_rman_replication_from_backups()
{
orasid=$1
orahome=$2
dbname=$3
srcdbbkpath=${4}
export NLS_DATE_FORMAT='DD-MM-RRRR HH24:MI:SS'
export ORACLE_SID=${orasid}
export ORACLE_HOME=${orahome}
export PATH=$ORACLE_HOME/bin:$PATH
#
case $dbname in
	TEST)
        rman @${rmanbasepath}rman_replication_from_backups_test.rcv USING "'${srcdbbkpath}'" \
            >${logfilepath}${dbname}_rman_replication_from_backups.log
        ;;
	$dbname)
		rman @${rmanbasepath}rman_replication_from_backups.rcv USING ${dbname} "'${srcdbbkpath}'" \
			>${logfilepath}${dbname}_rman_replication_from_backups.log
		;;
	*)
		echo "wrong database for replication";;
esac
}		

