delete_database_xxxxxx()
{
dbname=$1
ldbname=`echo "$dbname" | tr [A-Z] [a-z]`
#
orasid="$dbname"1
export ORACLE_SID=+ASM1
export ORACLE_HOME=/u01/app/12.1.0.1/grid
export NLS_DATE_FORMAT='DD-MM-RRRR HH24:MI:SS'
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_BASE=/u01/app/oracle
#
#
case $dbname in
        "DSGN")
                asmcmd rm xxxxxxxxxxxxxxxxxxxxxxxxxxx 
                ;;
        "DSTP")
                asmcmd rm xxxxxxxxxxxxxxxxxxxxxxxxxxx
                ;;
        "DBM01")
		asmcmd rm xxxxxxxxxxxxxxxxxxxxxxxxxxx
              	;;
        *)
                echo "cannot delete xxxxxx from +ASM";;
esac
}
