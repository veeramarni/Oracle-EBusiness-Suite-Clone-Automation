start_mount_database_sqlplus()
{
orasid=$1
orahome=$2
dbname=$3
export ORACLE_SID=${orasid}
export ORACLE_HOME=${orahome}
case $dbname in
        $dbname)
           "$ORACLE_HOME"/bin/sqlplus /" as sysdba" @${sqlbasepath}start_mount_database_sqlplus.sql \
		> > ${logfilepath}${dbname}_start_mount_database_sqlplus.log 
                ;;
        *)
                echo "wrong target database to start in MOUNT"
		;;
esac
}
