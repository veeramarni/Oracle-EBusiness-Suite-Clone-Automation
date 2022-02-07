its_crt_users()
{
dbname=$1
ldbname=`echo "$dbname" | tr [A-Z] [a-z]`
orasid="$dbname"1
lorasid="$ldbname"1
export ORACLE_SID="$orasid"
now=now=$(date "+%m/%d/%y %H:%M:%S")
if [ $dbname == "DBM01" ]
then
	lorasid="$ldbname"1
	export ORACLE_SID="$lorasid"
	export ORACLE_HOME=/u01/app/oracle/product/11.2.0.4/dbhome_1
else
	export ORACLE_HOME=/u01/app/oracle/product/11.2.0.4/dbhome_2
fi
"$ORACLE_HOME"/bin/sqlplus /" as sysdba" @/dbfs_direct/FS1/scripts/post_"$dbname"_script.sql \
	>/dbfs_direct/FS1/scripts/logs/"$dbname"/"$dbname"_users_sql_$(date +%a)_$(date +%F).log
}
