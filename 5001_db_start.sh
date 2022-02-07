#!/bin/bash
#
####################################################################################################
#                D A T A B A S E   S T A R T- Start Database on Server Start                 #
#                           1000_source_processing.sh
####################################################################################################
#
# Import properties file
#
. clone_environment.properties
#################################################
# Default Configuration							#
#################################################
trgbasepath="${basepath}targets/"
logfilepath="${basepath}logs/"
functionbasepath="${basepath}function_lib/"
custfunctionbasepath="${basepath}custom_lib/"
custsqlbasepath="${custfunctionbasepath}sql/"
sqlbasepath="${functionbasepath}sql/"
logfilename="$trgdbname"_DB_start_$(date +%a)"_$(date +%F).log"
abendfile="$trgbasepath""$trgdbname"/"$trgdbname"_5001_abend_step

####################################################################################################
#      add functions library                                                                       #
####################################################################################################
. ${functionbasepath}/usage.sh
. ${functionbasepath}/syncpoint.sh
. ${functionbasepath}/send_notification.sh
. ${functionbasepath}/check_database_status1.sh
. ${functionbasepath}/check_database_status2.sh
. ${functionbasepath}/start_database_sqlplus.sh 
. ${functionbasepath}/check_listener_status.sh
. ${functionbasepath}/start_listener.sh
#
########################################
#       VALIDATIONS                    #
########################################
#
if [ $# -lt 2 ]
then
	echo " ====> Abort!!!. Invalid database arguments for start"
		usage $0 :5001_db_start  "[DATABASE NAME]"
		########################################################################
		#   send notification  and exit                                        #
		########################################################################
		send_notification "$trgappname"_Start_abend "Invalid database name for replication" ${TOADDR} ${RTNADDR} ${CCADDR}
		exit 3
fi
echo "SCRIPT IS IN UNDER CONSTRUCTION !!!"
exit 99
#
# Check user  
#
os_user_check ${dbosuser}
	rcode=$?
	if [ "$rcode" -gt 0 ]
	then
		error_notification_exit $rcode "Wrong os user, user should be ${dbosuser}!!" $trgdbname 0  $LINENO
	fi
#
# Validate Directory
#
os_verify_or_make_directory ${logfilepath}
os_verify_or_make_directory ${trgbasepath}
os_verify_or_make_directory ${trgbasepath}${trgdbname}

#######################################################################################
restart=false
while read val1 val2
do
		stepnum=$val1
		linenum=$val2
		if [[ "$stepnum" !=  "0" ]]
		then
				restart=true
				echo ""
				echo "  RESTART LOCATION: "$stepnum" ,around line: "$linenum""
				echo "   SCRIPT LOCATION: /u01/app/oracle/scripts/refresh/5001_db_start.sh"
				echo "TASK LOG  LOCATION: /u01/app/oracle/scripts/refresh/logs/"
				echo " RUN LOG  LOCATION: /u01/app/oracle/scripts/refresh/logs/"
				echo ""
		else
				echo ""
				echo "   NORMAL LOCATION: "$stepnum" ,line: "$linenum""
				echo "   SCRIPT LOCATION: /u01/app/oracle/scripts/refresh/5001_db_start.sh"
				echo "TASK LOG  LOCATION: /u01/app/oracle/scripts/refresh/logs/"
				echo " RUN LOG  LOCATION: /u01/app/oracle/scripts/refresh/logs/"
				echo ""
				stepnum=`expr $stepnum + 50`
		fi
done < "$abendfile"
#
now=$(date "+%m/%d/%y %H:%M:%S")
echo $now >>$logfilepath$logfilename
#
now=$(date "+%m/%d/%y %H:%M:%S")" ====>  ########    database start has been started    ########"
echo $now >>$logfilepath$logfilename
#
for step in $(seq "$stepnum" 50 200)
do
		case $step in
		"50")
			echo "START   TASK: " $step "check_database_status1"
			########################################
			#  update log file:                    #
			#          check  DB status            #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Check $trgdbname status on node1"       
			echo $now >>${logfilepath}${logfilename}
			#
			check_database_status1 $trginstname $dbtargethomepath
			#
			rcode=$?
			if [ "$rcode" -eq 0 ]
			then
					error_notification_exit $rcode "Check database status for $trgdbname failed." $trgdbname $step $LINENO
			fi
			echo "END     TASK: " $step "check_database_status1"
		;;
		"100")
			echo "START   TASK:  $step start_database_sqlplus"
			########################################
			#  update log file:                    #
			#      start database 		           #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Start target Database $trgdbname"
			echo $now >>${logfilepath}${logfilename}
			#
			start_database_sqlplus $trginstname $dbtargethomepath $trgdbname
			#
			rcode=$?
			if [ $rcode -ne 0 ] 
			then
					error_notification_exit $rcode "Start database $trgdbname FAILED!!" $trgdbname $step $LINENO
			fi
			echo "END     TASK:  $step start_database_sqlplus"
		;;
		"150")
			echo "START   TASK:  $step start_listener"
			########################################
			#  update log file:                    #
			#      start listener 		           #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Start target listener $trgdbname "
			echo $now >>${logfilepath}${logfilename}
			#
			start_listener $trginstname $dbtargethomepath $trgdbname
			#
			rcode=$?
			if [ $rcode -ne 0 ] 
			then
					error_notification_exit $rcode "Start listener $trgdbname FAILED!!" $trgdbname $step $LINENO
			fi
			echo "END     TASK:  $step start_listener"
		;;
  		*)
            echo "step not found - step: $step around Line ===> " "$LINENO"
        ;;
        esac
done
