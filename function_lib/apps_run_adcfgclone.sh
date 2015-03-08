apps_run_adcfgclone()
{
clondir=$1
contxtfile=$2
appspass=$3
tm=$(date "+%m%d%y%H%M%S")
unset _logfile
_logfile=${3:-adcfgclone"$tm".log}
perl ${clondir}/adcfgclone.pl appsTier $contxtfile  << EOF
${appspass} -
n
EOF \
> ${logfilepath}${_logfile}
}