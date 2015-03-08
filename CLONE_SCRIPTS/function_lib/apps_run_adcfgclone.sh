apps_run_adcfgclone()
{
contxtfile=$1
appspass=$2
tm=$(date "+%m%d%y%H%M%S")
unset _logfile
_logfile=${3:-adcfgclone"$tm".log}
perl adcfgclone.pl appsTier $contxtfile  << EOF
${appspass}
n
EOF \
> ${logfilepath}${_logfile}
}