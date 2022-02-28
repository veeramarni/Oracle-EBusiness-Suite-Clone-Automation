setup_util_file_directories()
{
orapdb=$1
orahome=$2
contextfile=$3
srcappspwd=$4
srcdbsystem=$5
export ORACLE_SID=${orapdb}
export ORACLE_HOME=${orahome}
export PATH=$ORACLE_HOME/bin:$ORACLE_HOME/perl/bin:$PATH
export TNS_ADMIN=$ORACLE_HOME/network/admin/$ORACLE_SID'_'$HOSTNAME
source $ORACLE_HOME/${orapdb}_${HOSTNAME}.env
{ echo $srcappspwd ; echo $srcdbsystem ;}| perl $ORACLE_HOME/appsutil/bin/txkCfgUtlfileDir.pl -contextfile=$CONTEXT_FILE -oraclehome=$ORACLE_HOME -outdir=$ORACLE_HOME/appsutil/log -mode=setUtlFileDir -skipdirvalidation=Yes
}