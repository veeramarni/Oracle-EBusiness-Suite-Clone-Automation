#!/bin/bash
#
send_notification()
{
dist1="marni.srikanth@gmail.com"
dist2="marni.srikanth@gmail.com"
dist3="marni.srikanth@gmail.com"
dist4="marni.srikanth@gmail.com"
dist5="marni.srikanth@gmail.com"

if [ $# -lt 3 ]
then
        echo "Please provide MSG text"
	usage $0 :Notification Requirs  "[SUBJECT] [MSG] [DISTRIBUTION CODE 1..3]"
        return
else
	subj=$1
	msg=$2
	dstlist=$3
	echo "sub: " $subj
	echo "msg: " $msg
	echo "dislist: " $dstlist
	if [ $dstlist == 1 ]
	then
		echo "email group 1"
        	echo "$msg" | mail -s "$subj" "$dist1" -c "$dist2"
	elif [ $dstlist == 2 ]
	then
		echo "email group 2"
		 echo "$msg" | mail -s "$subj" "$dist2" -c "$dist5"
	elif [ $dstlist == 3 ]
        then
		echo "email group 3"
                 echo "$msg" | mail -s "$subj" "$dist3" -c "$dist2"
	else
		echo "email group 4"
		 echo "$msg" | mail -s "$subj" "$dist4" -c "$dist5"
	fi
fi
}

