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
dbhomepath="/u01/oracle/CONV9EBS/db/tech_st/11.2.0.4/"


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
logfilepath="/u01/app/oracle/scripts/refresh/logs/"
bkupbasepath="/migration/refresh/"
basepath="/u01/app/oracle/scripts/refresh/"
srcbasepath="/u01/app/oracle/scripts/refresh/source/"
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
        send_notification "$trgdbname"_Overlay_abend "Invalid database name for replication" 3
        exit 3
fi
#
trgdbname=$1
trgdbname=${trgdbname// }
trgdbname=`echo "$trgdbname" | tr [a-z] [A-Z]`
 
case $trgdbname in
	"DSGN")
		logfilename="$trgdbname"_Overlay_$(date +%a)"_$(date +%F).log"
		srcdbname="DPGN"
		;;
	"DSTP")
		logfilename="$trgdbname"_Overlay_$(date +%a)"_$(date +%F).log"
		srcdbname="DPTP"
		;;
	"DBM01")
		logfilename="$trgdbname"_Overlay_$(date +%a)"_$(date +%F).log"
		srcdbname="DBM01"
		;;
        *)	
        	########################################################################
	        #   send notification                                                  #
	        ########################################################################
        	send_notification "$trgdbname"_Overlay_abend "Invalid database name for replication" 3
                echo ""
                echo ""
                echo " ====> Abort!!!. Invalid staging database name"
                echo ""
                exit 4
                ;;
esac
#
abendfile="$srcbasepath""$srcdbname"/"$srcdbname"_abend_step
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
			#  send notification that DSGN overlay started                                      #
			#  Usage: send_notification SUBJECT MSG CODE [1..3]                                 #
			#  CODE [1..3] - 1:dor-oracle-oncall@dor.ga.gov     CC:dor-oracle-dba@dor.ga.gov    #
		        #    - 2:dor-its-batch-support@dor.ga.gov CC:dor-oracle-dba@dor.ga.gov              #
			#                3:Managed-Ops-Support_us@oracle.com CC:dor-oracle-dba@dor.ga.gov   # 
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

