apps_start_adstrtal()
{
unset _clondir
_clondir=$1
tm=$(date "+%m%d%y%H%M%S")
unset _logfile
_logfile=${3:-adstrtal"$tm".log}
${_clondir}"/adstrtal.sh" > ${logfilepath}${_logfile} <<EOFac
${2}
EOFac
}