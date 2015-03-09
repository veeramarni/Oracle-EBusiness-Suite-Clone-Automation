#!/usr/bin/ksh
#
####################################################################################################
#                S T A G I N G    O V E R L A Y - Source Database Tasks                            #
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
rmanbasepath="${functionbasepath}rman/"
abendfile="$trgbasepath""$trgdbname"/"$trgdbname"_1000_abend_step
logfilename="$trgdbname"_DB_Overlay_$(date +%a)"_$(date +%F).log"

####################################################################################################
#      add functions library                                                                       #
####################################################################################################
. ${functionbasepath}/usage.sh
. ${functionbasepath}/syncpoint.sh
. ${functionbasepath}/send_notification.sh
. ${functionbasepath}/check_database_status1.sh
. ${functionbasepath}/check_database_status2.sh
. ${functionbasepath}/start_rman_prod_backup.sh
. ${functionbasepath}/delete_sourcedb_backups.sh
#
########################################
#       VALIDATIONS                    #
########################################
#
if [ $# -lt 2 ]
then
	echo " ====> Abort!!!. Invalid database arguments for overlay"
        usage $0 :1000_overlay_staging  "[DATABASE NAME]"
        ########################################################################
        #   send notification  and exit                                        #
        ########################################################################
        send_notification "$trgappname"_Overlay_abend "Invalid database name for replication" ${TOADDR} ${RTNADDR} ${CCADDR}
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
os_verify_or_make_file ${abendfile} 0

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
                echo "   SCRIPT LOCATION: /u01/app/oracle/scripts/refresh/1000_overlay_staging1.sh"
                echo "TASK LOG  LOCATION: /u01/app/oracle/scripts/refresh/logs/"
                echo " RUN LOG  LOCATION: /u01/app/oracle/scripts/refresh/logs/"
                echo ""
        else
                echo ""
                echo "   NORMAL LOCATION: "$stepnum" ,line: "$linenum""
                echo "   SCRIPT LOCATION: /u01/app/oracle/scripts/refresh/1000_overlay_staging1.sh"
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
now=$(date "+%m/%d/%y %H:%M:%S")" ====>  ########    $srcdbname to $trgdbname overlay has been started - PART1    ########"
echo $now >>$logfilepath$logfilename
#
for step in $(seq "$stepnum" 50 250)
do
        case $step in
                "50")
			echo "START TASK: $step send_notification"
			#####################################################################################
			#  send notification that DB overlay started                                      #
			#####################################################################################
#			send_notification "$srcdbname"_backup_started  "$srcdbname backup started" 2 
			#
			########################################
			#  write an audit record in the log    #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Send start $srcdbname database backup Notification"
			echo $now >>$logfilepath$logfilename
			#
			echo "END   TASK: $step send_notification"
			;;
		"100")
			echo "START TASK: $step check_database_status1"
			########################################
			#  check source database status        #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Check $srcdbname status on node1"       
			echo $now >>$logfilepath$logfilename
			#
			check_database_status1 $srcdbname
	                rcode=$?
                        if [ "$rcode" -gt 0 ]
                        then
				rcode=$?
				echo "Check database status failed"
				now=$(date "+%m/%d/%y %H:%M:%S")" ====>Check $srcdbname status FAILD!!! RC=$rcode"
				echo $now >>$logfilepath$logfilename
				syncpoint $trgdbname $step "$LINENO"
			        ########################################################################
			        #   send notification                                                  #
			        ########################################################################
#			        send_notification "$trgdbname"_Overlay_abend "Check $srcdbname database status failed" 3
				echo "error.......Exit."
                                echo ""
				exit $rcode
			fi
			#
			echo "END   TASK: $step check_database_status1"
			;;
		"150")
			echo "START TASK: $step delete_sourcedb_backups"
			########################################
			#  delete old source database backups  #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Delete $srcdbname old backups"
			echo $now >>$logfilepath$logfilename
			#
			delete_sourcedb_backups $srcdbname
			#
	                rcode=$?
                        if [ "$rcode" -gt 0 ]
                        then
				rcode=$?
				echo "delete backups failed"
				now=$(date "+%m/%d/%y %H:%M:%S")" ====> Delete $srcdbname old backups FAILD!!! RC=$rcode"
				echo $now >>$logfilepath$logfilename
				syncpoint $trgdbname $step "$LINENO"
			        ########################################################################
			        #   send notification                                                  #
			        ########################################################################
#			        send_notification "$trgdbname"_Overlay_abend "Delete $srcdbname RMAN old backup failed" 3
				echo "error.......Exit."
                                echo ""
				exit $rcode
			fi
			echo "END   TASK: $step delete_sourcedb_backups"
			;; 
		"200")
			echo "START TASK: $step start_rman_prod_backups"
			########################################
			#  delete old  bckup completed      #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Delete $srcdbname old backups completed"
			echo $now >>$logfilepath$logfilename
			#
			########################################
			#  Start Source database backups       #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Start $srcdbname new backups"
			echo $now >>$logfilepath$logfilename
			#
			start_rman_prod_backup $srcdbname
			rcode=$?
			if [ $? -ne 0 ] # if RMAN connection fails
			then
				########################################
				#  update log file                     #
				########################################
				now=$(date "+%m/%d/%y %H:%M:%S")" ====> "$srcdbname" backup FAILED. Abort!! RC=$rcode"
				echo $now >>$logfilepath$logfilename
				syncpoint $trgdbname $step "$LINENO"
			        ########################################################################
			        #   send notification                                                  #
			        ########################################################################
#			        send_notification "$trgdbname"_Overlay_abend "Source database $srcdbname RMAN backup failed" 3
				echo "error in  : start_rman_prod_backups"
				echo ""
				exit 99
			fi
			echo "END   TASK: $step start_rman_prod_backups"
			;;
		"250")
			echo "START TASK: $step check_database_status2"
			########################################
			#  Source database backups completed   #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> $srcdbname new backups completed"
			echo $now >>$logfilepath$logfilename
			#
			########################################
			#  check source database after backups #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Check $srcdbname status after new backups"
			echo $now >>$logfilepath$logfilename
			#
			check_database_status2 $srcdbname
                        rcode=$?
                        if [ $? -ne 0 ] 
                        then
                                ########################################
                                #  update log file                     #
                                ########################################
                                now=$(date "+%m/%d/%y %H:%M:%S")" ====> $srcdbname Status FAILED. Abort!! RC=$rcode"
                                echo $now >>$logfilepath$logfilename
				syncpoint $trgdbname $step "$LINENO"
			        ########################################################################
			        #   send notification                                                  #
			        ########################################################################
#			        send_notification "$trgdbname"_Overlay_abend "Source database $srcdbname status failed" 3
                                echo "error in  : check_database_status2"
                                echo ""
                                exit 99
                        fi
			echo "END   TASK: $step check_database_status2"
			;;
		"300")
                        echo "START TASK: $step end-of $srcdbname database backup"
                        syncpoint $srcdbname "0 " "$LINENO"
                        echo "END   TASK: $step end-of $srcdbname database backup"
			;;
                   *)
                        echo "step not found - step: $step around Line ===> "  "$LINENO"
                ;;
        esac
done

