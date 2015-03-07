db_adconfig()
{
orasid=$1
orahome=$2
contextfile=$3
appspass=$4
export ORACLE_SID=${orasid}
export ORACLE_HOME=${orahome}
export PATH=$ORACLE_HOME/bin:$ORACLE_HOME/perl/bin:$PATH
cd $ORACLE_HOME/appsutil/bin
perl adconfig.pl contextfile=${contextfile} log=${logfilepath}${orasid}_adconfig.log << EOF
${appspass}
EOF \
> ${logfilepath}${orasid}_db_adconfig.log
}