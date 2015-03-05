#!/usr/bin/ksh
#
#####################################################################################################
#                S T A G I N G    O V E R L A Y - Source Apps Tasks                            		#
#                           1050_source_apps_processing.sh											#
#####################################################################################################
###########################################################################
# Modify settings below to suit your needs
###########################################################################
osuser="applmgr"
bkupbasepath="/orabackup/rmanbackups/"
basepath="/home/oracle/script/script/CLONE_SCRIPTS/"
apphomepath="/ovprd-ebsapp1/applmgr/PRODEBS/apps/"


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


####################################################################################################
#      add functions library                                                                       #
####################################################################################################
. /u01/app/oracle/scripts/refresh/function_lib/usage.sh
. /u01/app/oracle/scripts/refresh/function_lib/syncpoint.sh
. /u01/app/oracle/scripts/refresh/function_lib/send_notification.sh
. /u01/app/oracle/scripts/refresh/function_lib/check_database_status1.sh
. /u01/app/oracle/scripts/refresh/function_lib/check_database_status2.sh
. /u01/app/oracle/scripts/refresh/function_lib/start_rman_prod_backup.sh
. /u01/app/oracle/scripts/refresh/function_lib/delete_sourcedb_backups.sh
#
########################################
#       VALIDATIONS                    #
########################################
#
if [ $# -lt 1 ]
then
	echo " ====> Abort!!!. Invalid database name for overlay"
        usage $0 :1000_overlay_staging  "[DATABASE NAME]"
        ########################################################################
        #   send notification                                                  #
        ########################################################################
        send_notification "$trgappname"_Overlay_abend "Invalid database name for replication" 3
        exit 3
fi
#
trgappname=$1
trgapname=${trgappname// }
trgappname=`echo "$trgappname" | tr [a-z] [A-Z]`
 
case $trgappname in
	"PRODEBS")
		logfilename="$trgappname"_Overlay_$(date +%a)"_$(date +%F).log"
		srcappname="PRODEBS"
		;;
        *)	
        	########################################################################
	        #   send notification                                                  #
	        ########################################################################
        	send_notification "$trgappname"_Overlay_abend "Invalid database name for replication" 3
                echo ""
                echo ""
                echo " ====> Abort!!!. Invalid staging database name"
                echo ""
                exit 4
                ;;
esac
#
# Check user  
#
os_user_check ${osuser}
	rcode=$?
	if [ "$rcode" -gt 0 ]
	then
		echo "Not a valid user failed. Abrt!!! RC=" "$rcode"
		########################################
		#  update log file                     #
		########################################
		now=$(date "+%m/%d/%y %H:%M:%S")" ====> Check user failed. Abort!! \
		RC=""$rcode"       
		echo $now >>${logfilepath}${logfilename}
		syncpoint $trgappname $step "$LINENO"
		########################################################################
		#   send notification                                                  #
		########################################################################
		send_notification "$trgappname"_Overlay_abend "Not a valid user " 3
		echo "error.......Exit."
		echo ""
		exit $step
	fi

#
abendfile="$srcbasepath""$srcappname"/"$srcappname"_abend_step
#
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
		echo "   SCRIPT LOCATION: ${basepath}$0"
                echo "TASK LOG  LOCATION: ${trgbasepath}${trgdbname}/"
                echo " RUN LOG  LOCATION: ${logfilepath}"
		echo ""
	else
		echo ""
                echo "   NORMAL LOCATION: "$stepnum" ,line: "$linenum""
		echo "   SCRIPT LOCATION: ${basepath}$0"
                echo "TASK LOG  LOCATION: ${trgbasepath}${trgdbname}/"
                echo " RUN LOG  LOCATION: ${logfilepath}"
		echo ""
		stepnum=`expr $stepnum + 50`
        fi
done < "$abendfile"
#
now=$(date "+%m/%d/%y %H:%M:%S")
echo $now >>$logfilepath$logfilename
#
now=$(date "+%m/%d/%y %H:%M:%S")" ====>  ########    $srcappname to $trgappname overlay has been started - PART1    ########"
echo $now >>$logfilepath$logfilename
#
for step in $(seq "$stepnum" 50 250)
do
        case $step in
        "50")
			echo "START TASK: $step send_notification"
			#####################################################################################
			#  send notification that DSGN overlay started                                      #
			#  Usage: send_notification SUBJECT MSG CODE [1..3]                                 #
			#####################################################################################
			send_notification "$srcappname"_backup_started  "$srcappname backup started" 2 
			#
			########################################
			#  write an audit record in the log    #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Send start $srcappname database backup Notification"
			echo $now >>$logfilepath$logfilename
			#
			echo "END   TASK: $step send_notification"
			;;
		"100")
			echo "START TASK: $step check_database_status1"
			########################################
			#  check source database status        #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Check $srcappname status on node1"       
			echo $now >>$logfilepath$logfilename
			#
			check_database_status1 $srcappname
	                rcode=$?
                        if [ "$rcode" -gt 0 ]
                        then
				rcode=$?
				echo "Check database status failed"
				now=$(date "+%m/%d/%y %H:%M:%S")" ====>Check $srcappname status FAILD!!! RC=$rcode"
				echo $now >>$logfilepath$logfilename
				syncpoint $trgappname $step "$LINENO"
			        ########################################################################
			        #   send notification                                                  #
			        ########################################################################
#			        send_notification "$trgappname"_Overlay_abend "Check $srcappname database status failed" 3
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
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Delete $srcappname old backups"
			echo $now >>$logfilepath$logfilename
			#
			delete_sourcedb_backups $srcappname
			#
	                rcode=$?
                        if [ "$rcode" -gt 0 ]
                        then
				rcode=$?
				echo "delete backups failed"
				now=$(date "+%m/%d/%y %H:%M:%S")" ====> Delete $srcappname old backups FAILD!!! RC=$rcode"
				echo $now >>$logfilepath$logfilename
				syncpoint $trgappname $step "$LINENO"
			        ########################################################################
			        #   send notification                                                  #
			        ########################################################################
#			        send_notification "$trgappname"_Overlay_abend "Delete $srcappname RMAN old backup failed" 3
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
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Delete $srcappname old backups completed"
			echo $now >>$logfilepath$logfilename
			#
			########################################
			#  Start Source database backups       #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Start $srcappname new backups"
			echo $now >>$logfilepath$logfilename
			#
			start_rman_prod_backup $srcappname
			rcode=$?
			if [ $? -ne 0 ] # if RMAN connection fails
			then
				########################################
				#  update log file                     #
				########################################
				now=$(date "+%m/%d/%y %H:%M:%S")" ====> "$srcappname" backup FAILED. Abort!! RC=$rcode"
				echo $now >>$logfilepath$logfilename
				syncpoint $trgappname $step "$LINENO"
			        ########################################################################
			        #   send notification                                                  #
			        ########################################################################
#			        send_notification "$trgappname"_Overlay_abend "Source database $srcappname RMAN backup failed" 3
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
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> $srcappname new backups completed"
			echo $now >>$logfilepath$logfilename
			#
			########################################
			#  check source database after backups #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Check $srcappname status after new backups"
			echo $now >>$logfilepath$logfilename
			#
			check_database_status2 $srcappname
                        rcode=$?
                        if [ $? -ne 0 ] 
                        then
                                ########################################
                                #  update log file                     #
                                ########################################
                                now=$(date "+%m/%d/%y %H:%M:%S")" ====> $srcappname Status FAILED. Abort!! RC=$rcode"
                                echo $now >>$logfilepath$logfilename
				syncpoint $trgappname $step "$LINENO"
			        ########################################################################
			        #   send notification                                                  #
			        ########################################################################
#			        send_notification "$trgappname"_Overlay_abend "Source database $srcappname status failed" 3
                                echo "error in  : check_database_status2"
                                echo ""
                                exit 99
                        fi
			echo "END   TASK: $step check_database_status2"
			;;
		"300")
                        echo "START TASK: $step end-of $srcappname database backup"
                        syncpoint $srcappname "0 " "$LINENO"
                        echo "END   TASK: $step end-of $srcappname database backup"
			;;
                   *)
                        echo "step not found - step: $step around Line ===> "  "$LINENO"
                ;;
        esac
done

