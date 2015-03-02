#!/bin/bash
#
send_notification()
{
dist1="DOR-ITS-BATCH-SUPPORT@dor.ga.gov"
dist2="DOR-ORACLE-DBA@dor.ga.gov"
dist3="oncdb2dba@DOR.GA.GOV"
dist4="oncdb2dba@DOR.GA.GOV"
dist5="ramzi.salameh@dor.ga.gov"
#
#dist1="ramzi.salameh@dor.ga.gov"
#dist2="ramzi.salameh@dor.ga.gov"
#dist3="ramzi.salameh@dor.ga.gov"
#dist4="ramzi.salameh@dor.ga.gov"
#
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

