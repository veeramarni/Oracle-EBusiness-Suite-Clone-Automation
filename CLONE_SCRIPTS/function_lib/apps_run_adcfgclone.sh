apps_run_adcfgclone()
{
contxtfile=$1
perl adcfgclone.pl appsTier $contxtfile << EOF
<appsPass>
n
EOF
}