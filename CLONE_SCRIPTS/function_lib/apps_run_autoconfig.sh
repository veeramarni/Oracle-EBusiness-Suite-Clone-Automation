apps_run_autoconfig()
{
unser _clondir
_clondir=$1
unset _appspwd
_appspwd=$2
tm=$(date "+%m%d%y%H%M%S")
unset _logfile
_logfile=${3:-adautoconfig"$tm".log}
${_clondir}adautoconfig.sh >${logfilepath}${_logfile} << EOF
${_appspwd}
EOF
}