os_kill_process_homepath()
{
tm=$(date "+%m%d%y%H%M%S")
unset _path
_path="$1"
unset logfile
logfile=${2:-kill_processors"$tm".log}
RESULT=` ps -ef|grep ${_path}|grep -v grep`
if [ "${RESULT:-null}" != null ]; then
	echo "`date`: killing $RESULT" > ${logfilepath}${logfile}
	kill -9 `ps -ef|grep ${_path}|grep -v grep|awk '{print $2}'`
    echo "`date`: Process running from ${_path} are killed" >> ${logfilepath}${logfile}
else
	echo "`date`: No process running from ${_path}" >> ${logfilepath}${logfile}
fi
}
