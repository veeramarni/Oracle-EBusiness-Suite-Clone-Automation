stop_database_sqlplus()
{
orasid=$1
orahome=$2
dbname=$3
export ORACLE_SID=${orasid}
export ORACLE_HOME=${orahome}
case $dbname in
        $dbname)
       "$ORACLE_HOME"/bin/sqlplus /" as sysdba" @${sqlbasepath}stop_database_sqlplus.sql \
		> ${logfilepath}${dbname}_stop_database_sqlplus.log
		                ;;
        *)
                echo "wrong database to shutdown"
		;;
esac
}
