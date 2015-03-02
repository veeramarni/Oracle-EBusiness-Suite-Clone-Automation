start_database_mount()
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
case $dbname in
        "DSGN")
            "$ORACLE_HOME"/bin/sqlplus /" as sysdba" @/u01/app/oracle/scripts/refresh/targets/DSGN/DSGN_start_database_mount.sql \
		> /u01/app/oracle/scripts/refresh/logs/DSGN_start_database_mount.log
                ;;
        "DSTP")
            "$ORACLE_HOME"/bin/sqlplus /" as sysdba" @/u01/app/oracle/scripts/refresh/targets/DSTP/DSTP_start_database_mount.sql \
		> /u01/app/oracle/scripts/refresh/logs/DSTP_start_database_mount.log
                ;;
        "DBM01")
           "$ORACLE_HOME"/bin/sqlplus /" as sysdba" @/u01/app/oracle/scripts/refresh/targets/DBM01/DBM01_start_database_mount.sql \
		> /u01/app/oracle/scripts/refresh/logs/DBM01_start_database_mount.log 
                ;;
        *)
                echo "wrong target database to start in MOUNT"
		;;
esac
}
