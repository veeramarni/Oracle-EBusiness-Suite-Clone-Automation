error_notification_exit()
{
unset rcode
_rcode=$1
unset _errormessg
_errormessg=$2
unset _trgname
_trgname=$3
unset _step
_step=$4
unset _lineno
_lineno=$5
	now=$(date "+%m/%d/%y %H:%M:%S")" ====> ${_errormessg}" RC=${_rcode}
	echo $now
	echo $now >>${logfilepath}${logfilename}
	syncpoint ${_trgname} ${_step} "${_lineno}"
	########################################################################
	#   send notification                                                  #
	########################################################################
	send_notification "${_trgname}"_Overlay_abend "${_errormessg}" ${TOADDR} ${RTNADDR} ${CCADDR}
	echo "error.......Exit."
	echo ""
	exit ${_step}
}