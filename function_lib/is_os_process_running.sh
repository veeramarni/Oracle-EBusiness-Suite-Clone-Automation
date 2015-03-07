is_os_process_running()
{
SERVICE="$1"
RESULT=`ps axho comm| grep -w ${SERVICE}`

if [ "${RESULT:-null}" = null ]; then
    echo "`date`: $SERVICE service running"
    return 1
else
	echo "`date`: $SERVICE service NOT running"
    return 0
fi
}