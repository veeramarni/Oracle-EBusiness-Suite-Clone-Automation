send_notification()
{
HDR="`date +%m%d%y`"
if [ $# -lt 3 ]
then
        echo "Please provide MSG text"
	usage $0 :Notification Requires  "[SUBJECT] [MSG] [TOADDR] ...(optional)..[RTNADDR] [CCADDR] "
        return
else
	subj=$1
	msg=$2
	toaddr=$3
	rtnaddr=$4
	ccaddr=$5
	echo "sub: " $subj
	echo "msg: " $msg
	echo "dislist: " $dstlist
	echo "toaddr: " $toaddr
	echo "ccaddr: " $ccaddr
	echo "rtnaddr: " $rtnaddr
	if [ $# == 3 ]
	then
		echo "email toaddress"
        mail -s $subj $toaddr<$msg
	elif [ $# == 4 ]
	then
		echo "email toaddress with return address"
		mail -s $subj -r $rtnaddr $toaddr<$msg
	elif [ $# == 5 ]
        then
		echo "email toaddress and cc with return address"
		# Now mail report out with a Return Address (not user thsat ran it)
		# CC addresses and an TO
        mail -s $subj -r $rtnaddr -c $ccaddr $toaddr<$msg
	else 
	    echo "In valid number of arguments"
	fi
fi
}

