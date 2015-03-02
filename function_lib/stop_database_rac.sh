stop_database_rac()
{
dbname=$1
ldbname=`echo "$dbname" | tr [A-Z] [a-z]`
orasid="$dbname"1
lorasid="$ldbname"1
if [ $dbname == "DBM01" ]
then
        lorasid="$ldbname"1
        export ORACLE_SID="$lorasid"
        export ORACLE_HOME=/u01/app/oracle/product/11.2.0.4/dbhome_1
        $ORACLE_HOME/bin/srvctl stop database -d dbm01  \
		>/u01/app/oracle/scripts/refresh/logs/DBM01_stop_database_rac.log
else
        export ORACLE_HOME=/u01/app/oracle/product/11.2.0.4/dbhome_2
        $ORACLE_HOME/bin/srvctl stop database -d $dbname  \
		>/u01/app/oracle/scripts/refresh/logs/"$dbname"_stop_database_rac.log
fi

}
