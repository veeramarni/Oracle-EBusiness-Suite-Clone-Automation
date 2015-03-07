apps_run_adcfgclone()
{
contxtfile=$1
appspass=$2
logfile=${3:-adcfgclone"$now".log}
perl adcfgclone.pl appsTier $contxtfile << EOF
$appspass
EOF  \
> ${logfilepath}${logfile}
}