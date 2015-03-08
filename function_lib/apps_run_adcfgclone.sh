apps_run_adcfgclone()
{
clondir=$1
contxtfile=$2
appspass=$3
tm=$(date "+%m%d%y%H%M%S")
unset _logfile
_logfile=${4:-adcfgclone"$tm".log}
perl $ORACLE_HOME/appsutil/bin/adconfig.pl contextfile=${contextfile} log=${logfilepath}${orasid}_adconfig.log << EOF
${appspass}
EOF \
> ${logfilepath}${orasid}_db_adconfig.log
}