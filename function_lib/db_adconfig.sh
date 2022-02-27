db_adconfig()
{
orapdb=$1
orahome=$2
contextfile=$3
appspass=$4
export ORACLE_SID=${orapdb}
export ORACLE_HOME=${orahome}
export PATH=$ORACLE_HOME/bin:$ORACLE_HOME/perl/bin:$PATH
export TNS_ADMIN=$ORACLE_HOME/network/admin/$ORACLE_SID'_'$HOSTNAME
cd $ORACLE_HOME/appsutil/bin
perl adconfig.pl contextfile=${contextfile} log=${logfilepath}${orapdb}_adconfig.log > ${logfilepath}${orapdb}_db_adconfig.log << EOF
${appspass}
EOF
}