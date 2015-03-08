os_kill_process_homepath()
{
unset _path
_path="$1"
RESULT=` ps -ef|grep ${_path}|grep -v grep`
if [ "${RESULT:-null}" = null ]; then
	echo "`date`: killing $RESULT"
	kill -9 `ps -ef|grep ${_path}|grep -v grep|awk '{print $2}'`
    echo "`date`: Process running from ${_path} are killed"
else
	echo "`date`: No process running from ${_path}"
fi
}
