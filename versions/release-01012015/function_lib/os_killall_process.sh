os_killall_process()
{
SERVICE="$1"
RESULT=` ps axho comm| grep -w ${SERVICE}`

if [ "${RESULT:-null}" != null ]; then
	echo "`date`: killing $RESULT"
	killall -q -0 ${SERVICE}
    echo "`date`: $SERVICE service killed"
else
	echo "`date`: $SERVICE service NOT running"
fi
}