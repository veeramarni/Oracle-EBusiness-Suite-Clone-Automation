alter_database_archivelog()
{
dbname=$1
dbhome=$2
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
case $dbname in
        "DSGN")
                "$ORACLE_HOME"/bin/sqlplus /" as sysdba"    \
			@/u01/app/oracle/scripts/refresh/targets/DSGN/DSGN_alter_database_archivelog.sql \
			> /u01/app/oracle/scripts/refresh/logs/DSGN_alter_database_archivelog.log
                ;;
        "DSTP")
                "$ORACLE_HOME"/bin/sqlplus /" as sysdba"     \
			@/u01/app/oracle/scripts/refresh/targets/DSTP/DSTP_alter_database_archivelog.sql \
			> /u01/app/oracle/scripts/refresh/logs/DSTP_alter_database_archivelog.log
                ;;
        "DBM01")
               "$ORACLE_HOME"/bin/sqlplus /" as sysdba"       \
			@/u01/app/oracle/scripts/refresh/targets/DBM01/DBM01_alter_database_archivelog.sql \
			> /u01/app/oracle/scripts/refresh/logs/DBM01_alter_database_archivelog.log
                ;;
        *)
                echo "wrong target database for ALTER DATABASE ARCHIVELOG"
		;;
esac
}
