apps_run_adcfgclone()
{
clondir=$1
contxtfile=$2
appspass=$3
tm=$(date "+%m%d%y%H%M%S")
unset _logfile
_logfile=${4:-adcfgclone"$tm".log}
perl adcfgclone.pl <<EOF1
${appspass}
EOF1 > ${logfilepath}${_logfile}
}