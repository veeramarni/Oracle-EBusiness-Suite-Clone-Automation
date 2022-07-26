db_adconfig()
{
orapdb=$1
orahome=$2
contextname=$3
appspass=$4
export ORACLE_SID=${orapdb}
export ORACLE_HOME=${orahome}
export PATH=$ORACLE_HOME/bin:$ORACLE_HOME/perl/bin:$PATH
clonedir=${orahome}/appsutil/scripts/${contextname}
${clonedir}"/adautocfg.sh" > ${logfilepath}${orapdb}_db_adconfig.log << EOF
${appspass}
EOF
}