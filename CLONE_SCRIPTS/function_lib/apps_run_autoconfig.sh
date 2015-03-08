apps_run_autoconfig()
{
unser _clondir
_clondir=$1
tm=$(date "+%m%d%y%H%M%S")
unset _logfile
_logfile=${3:-adautoconfig"$tm".log}
${_clondir}"/adautoconfig.sh" > ${logfilepath}${_logfile} <<EOFac
${2}
EOFac
}