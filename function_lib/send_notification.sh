send_notification()
{
HDR="`date +%m%d%y`"
unset ct
ct=$#
if [ $ct -lt 3 ]
then
        echo "Please provide MSG text"
		usage $0 :Notification Requires  "[SUBJECT] [MSG] [TOADDR] ...(optional)..[RTNADDR] [CCADDR] "
		usage $0 :Notification Requires  "[SUBJECT] file [FILE_NAME] [TOADDR] ...(optional)..[RTNADDR] [CCADDR] "
        return
else
	subj=$1
	msg=$2
	toaddr=$3
	rtnaddr=$4
	ccaddr=$5
	if [ $ct == 3 ]
	then
		echo "email toaddress"
        echo "$msg" | mail -s "$subj" $toaddr
	elif [ $ct == 4 ]
	then
		echo "email toaddress with return address"
		if [ "$msg" == "file" ]
		then
		    msg=$toaddr
		    toaddr=$rtnaddr
			mail -s "$subj" $toaddr < $msg
		else
			echo "$msg" | mail -s "$subj" $toaddr -- -f $rtnaddr
		fi
	elif [ $ct == 5 ]
        then
		echo "email toaddress and cc with return address"
		# Now mail report out with a Return Address (not user thsat ran it)
		# CC addresses and an TO
		if [ "$msg" == "file" ]
		then
			msg=$toaddr
		    toaddr=$rtnaddr
		    rtnaddr=$ccaddr
		    mail -s "$subj" "$toaddr" -- -f "$rtnaddr" < $msg
		else 
        	echo "$msg" | mail -s "$subj" -c $ccaddr "$toaddr" -- -f "$rtnaddr"
        fi
    elif [ $ct == 6 ]
    	then
		echo "email toaddress and cc with return address"
		# Now mail report out with a Return Address (not user thsat ran it)
		# CC addresses and an TO
		if [ "$msg" == "file" ]
		then
			msg="$toaddr"
		    toaddr="$rtnaddr"
		    rtnaddr="$ccaddr"
		    ccaddr=$6
		    mail -s "$subj" -c $ccaddr $toaddr -- -f $rtnaddr < $msg
		else 
        	echo "In valid number of arguments"
        fi
	else 
	    echo "In valid number of arguments"
	fi
fi
}

