apps_run_adcfgclone()
{
clondir=$1
contxtfile=$2
appspass=$3
tm=$(date "+%m%d%y%H%M%S")
unset _logfile
_logfile=${4:-adcfgclone"$tm".log}
perl ${clondir}/adcfgclone.pl appsTier $contxtfile > ${logfilepath}${_logfile} <<EOF1
${appspass}
n
EOF1
}