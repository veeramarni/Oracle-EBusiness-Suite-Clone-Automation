apps_run_adcfgclone()
{
contxtfile=$1
logfile=${2:-adcfgclone"$now".log}
perl adcfgclone.pl appsTier $contxtfile << EOF
<appsPass>
n
EOF  \
> ${logfilepath}${logfile}
}