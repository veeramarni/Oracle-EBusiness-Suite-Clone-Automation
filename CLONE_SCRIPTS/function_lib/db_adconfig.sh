db_adconfig()
{
orasid=$1
orahome=$2
export ORACLE_SID=${orasid}
export ORACLE_HOME=${orahome}
cd $ORACLE_HOME/appsutil/bin
perl adconfig.pl > ${logfilepath}${orasid}_db_adconfig.log
}