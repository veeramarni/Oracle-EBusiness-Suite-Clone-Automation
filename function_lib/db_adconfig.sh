db_adconfig()
{
orasid=$1
orahome=$2
export ORACLE_SID=${orasid}
export ORACLE_HOME=${orahome}
export PATH=$ORACLE_HOME/bin:$PATH
cd $ORACLE_HOME/appsutil/bin
expect "Enter the full file path to the Context file"
send $CONTEXT_FILE
perl adconfig.pl 
#> ${logfilepath}${orasid}_db_adconfig.log
}