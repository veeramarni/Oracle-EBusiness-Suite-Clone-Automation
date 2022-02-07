start_database_srvctl()
{
orasid=$1
orahome=$2
dbname=$3
export ORACLE_SID=${orasid}
export ORACLE_HOME=${orahome}
case $dbname in
	$dbname)
    $ORACLE_HOME/bin/srvctl start database -d $dbname   >${logfilepath}${dbname}_start_database_srvctl.log 
		;;
	*)
		echo "wrong database to startup";;
esac
}
