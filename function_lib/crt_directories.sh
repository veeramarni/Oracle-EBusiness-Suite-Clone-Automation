crt_directories()
{
dbname=$1
ldbname=`echo "$dbname" | tr [A-Z] [a-z]`
orasid="$dbname"1
lorasid="$ldbname"1
export ORACLE_SID="$orasid"
if [ $dbname == "DBM01" ]
then
	lorasid="$ldbname"1
	export ORACLE_SID="$lorasid"
	export ORACLE_HOME=/u01/app/oracle/product/11.2.0.4/dbhome_1
else
	export ORACLE_HOME=/u01/app/oracle/product/11.2.0.4/dbhome_2
fi
"$ORACLE_HOME"/bin/sqlplus /" as sysdba" @/u01/app/oracle/scripts/refresh/targets/"$dbname"/"$dbname"_crt_directories.sql
}
