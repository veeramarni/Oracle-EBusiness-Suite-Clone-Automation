is_os_process_running()
{
unset _service
_service="$1"
_res=`ps -ef|grep ${_service}|grep -v grep`
if [ "${_res:-null}" != null ]; then
    echo "`date`: ${_service} service running"
    return 0
else
	echo "`date`: ${_service} service NOT running"
    return 1
fi
}