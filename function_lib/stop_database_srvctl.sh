stop_database_rac()
{
orasid=$1
orahome=$2
dbname=$3
export ORACLE_SID=${orasid}
export ORACLE_HOME=${orahome}

case $orasid in
	$orasid)
	$ORACLE_HOME/bin/srvctl stop database -d $dbname  \
		>${logfilepath}${dbname}_stop_database_rac.log
		;;
	*)
		echo "wrong database to shutdown";;
esac
}
