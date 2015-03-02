start_database_rac()
{
dbname=$1
ldbname=`echo "$dbname" | tr [A-Z] [a-z]`
orasid="$dbname"1
lorasid="$ldbname"1
if [ $dbname == "DBM01" ]
then
	srvctl start database -d $ldbname  >  /u01/app/oracle/scripts/refresh/logs/DBM01_start_database_rac.log
else
	srvctl start database -d $dbname   > /u01/app/oracle/scripts/refresh/logs/"$dbname"_start_database_rac.log 
fi
}
