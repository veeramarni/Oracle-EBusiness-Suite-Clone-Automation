oem_blackout_start()
{
unset ct
ct=$#
if [ $ct -lt 3 ]
then
        echo "Please provide required arguments"
	usage $0 :oem_blackout_start Requires  "[AGENT BIN PATH] [BLACKOUT NAME] [TARGETS] ...(optional)..[TARGET TYPE] [DURATION] "
        return
else
unset _path
_path=$1
unset _bkname
_path=$2
unset _target
_target=$3
unset _targettype
_targettype=$4
## formatfor d is "[days] hh:mm"
unset _d
_d=$5
	if [ $ct == 3 ]
	then
		${_path}/emctl start blackout ${_bkname} ${_target}
	elif [ $ct == 4 ]
	then
		${_path}/emctl start blackout ${_bkname} ${_target}:${_targettype} 
	elif [ $ct == 5 ]
	then
		${_path}/emctl start blackout ${_bkname} ${_target}:${_targettype} -d ${_d}
	fi
fi
}