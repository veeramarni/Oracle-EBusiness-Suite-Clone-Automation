start_mount_database_node1()
{
dbname=$1
ldbname=`echo "$dbname" | tr [A-Z] [a-z]`
orasid="$dbname"1
lorasid="$ldbname"1
export ORACLE_SID="$orasid"
if [ $dbname == "DBM01" ]
then
	srvctl start instance -i dbm011 -d dbm01 -o mount  \
		> /u01/app/oracle/scripts/refresh/logs/DBM01_start_mount_database_node1.log
else
	srvctl start instance -i $orasid -d $dbname -o mount \
		> /u01/app/oracle/scripts/refresh/logs/"$dbname"_start_mount_database_node1.log
fi
}
