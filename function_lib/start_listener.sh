start_listener()
{
orasid=$1
orahome=$2
dbname=$3
export ORACLE_SID=${orasid}
export ORACLE_HOME=${orahome}
case $dbname in
        $dbname)
           "$ORACLE_HOME"/bin/lsnrctl start \
		> ${logfilepath}${orasid}_start_listener.log
                ;;
        *)
                echo "wrong target listener to start in NOMOUNT"
		;;
esac
}
