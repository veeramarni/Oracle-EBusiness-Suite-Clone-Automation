#!/usr/bin/ksh
#
#####################################################################################################
#                S T A G I N G    O V E R L A Y - target Apps Tasks                            		#
#                           3050_target_apps_processing.sh											#
#####################################################################################################
###########################################################################
# Modify settings below to suit your needs
###########################################################################
appsosuser="applmgr"
appbkupbasepath="/ovbackup/APPS_BACKUP/"
basepath="/ovbackup/EBS_SCRIPTS/CLONE_SCRIPTS/"

### EMAIL
TOADDR="marni.srikanth@gmail.com"
CCADDR=" marni.srikanth@gmail.com,stackflow1@gmail.com"
RTNADDR="noreply@krispycorp.com"
#
trgappname=$1
trgapname=${trgappname// }
trgappname=`echo "$trgappname" | tr [a-z] [A-Z]`
 
case $trgappname in
	"PRODEBS")
		logfilename="$trgappname"_Overlay_$(date +%a)"_$(date +%F).log"
		srcappname="PRODEBS"
		apphomepath="/ovprd-ebsapp1/applmgr/PRODEBS/apps/"
		appbkupdir=$appbkupbasepath"PRODEBS/"
		apptargethomepath="/u01/applmgr/CONV9EBS/apps/"
		;;
    "CONV9EBS")
	    logfilename="$trgappname"_Overlay_$(date +%a)"_$(date +%F).log"
		srcappname="CONV9EBS"
		apphomepath="/u01/applmgr/CONV9EBS/apps/"
		apptargethomepath="/u01/applmgr/CONV9EBS/apps/"
		appbkupdir=$appbkupbasepath"CONV9EBS/"
		;;
        *)	
                echo ""
                echo ""
                echo " ====> Abort!!!. Invalid staging app name"
                echo ""
                exit 4
                ;;
esac
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
abendfile="$trgbasepath""$srcappname"/"$srcappname"_abend_step


####################################################################################################
#      add functions library                                                                       #
####################################################################################################
    
. ${functionbasepath}/syncpoint.sh   
. ${functionbasepath}/send_notification.sh
. ${functionbasepath}/os_tar_gz_file.sh
. ${functionbasepath}/os_delete_move_file.sh
. ${functionbasepath}/os_user_check.sh
. ${functionbasepath}/os_verify_or_make_directory.sh
. ${functionbasepath}/os_verify_or_make_file.sh
. ${functionbasepath}/is_os_file_exist.sh
. ${functionbasepath}/is_os_process_running.sh
. ${custfunctionbasepath}/error_notification_exit.sh
#
########################################
#       VALIDATIONS                    #
########################################
#
if [ $# -lt 1 ]
then
	echo " ====> Abort!!!. Invalid apps name for overlay"
        usage $0 :1000_overlay_staging  "[APPS NAME]"
        ########################################################################
        #   send notification                                                  #
        ########################################################################
        send_notification "$trgappname"_Overlay_abend "Invalid apps name for replication" ${TOADDR} ${RTNADDR} ${CCADDR}
        exit 3
fi
#

#
# Check user  
#
os_user_check ${appsosuser}
	rcode=$?
	if [ "$rcode" -gt 0 ]
	then
		error_notification_exit $rcode "Wrong os user, user should be ${appsosuser}!!" $trgappname 0
	fi
#
# Validate Directory
#
os_verify_or_make_directory ${logfilepath}
os_verify_or_make_directory ${appbkupdir}
os_verify_or_make_directory ${trgbasepath}
os_verify_or_make_directory ${trgbasepath}${srcappname}
os_verify_or_make_file ${abendfile} 0

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
now=$(date "+%m/%d/%y %H:%M:%S")" ====>  ########    $srcappname to $trgappname overlay has been started - PART3    ########"
echo $now >>$logfilepath$logfilename
#
for step in $(seq "$stepnum" 50 250)
do
        case $step in
        "50")
			echo "START TASK: $step send_notification"
			#####################################################################################
			#  send notification that APPS overlay started                                      #
			#  Usage: send_notification SUBJECT MSG CODE [1..3]                                 #
			#####################################################################################
			send_notification "$srcappname"_backup_started  "$srcappname backup started" ${TOADDR} ${RTNADDR} ${CCADDR}
			#
			########################################
			#  write an audit record in the log    #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Send start $srcappname apps backup Notification"
			echo $now >>$logfilepath$logfilename
			#
			echo "END   TASK: $step send_notification"
		;;
		"100")
			########################################
			#  check source apps status            #
			########################################
			echo "START TASK: $step apps status check"
			if is_os_process_running FNDLIBR 
			then
				echo "Concurrent process is running.."
				os_killall_process FNDLIBR
			else 
				echo "Concurrent process is not running.."
			fi
			echo "END   TASK: $step apps status check"
		;;
		"150")
			echo "START TASK: $step os_untar_gz_file"
			########################################
			#  restore apps from  backup		   #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Delete $srcappname old backups"
			echo $now >>$logfilepath$logfilename
			#
			if is_os_file_exist ${appbkupdir}${srcappname}.tar.gz 
			then
			    echo "Moving previous backup file ${appbkupdir}${srcappname}.tar.gz ${appbkupdir}${srcappname}.tar.gz.$appender"
				os_untar_gz_file ${appbkupdir}${srcappname}.tar.gz ${apptargethomepath}
			else 
			    error_notification_exit $rcode "Apps Backup not found." $trgappname $step
			fi
			#
	        rcode=$?
            if [ "$rcode" -gt 0 ]
            then
				error_notification_exit $rcode "Restore apps files FAILED!!" $trgappname $step
			fi
			echo "END   TASK: $step os_untar_gz_file"
		;; 
		"200")
			#########################################
			#  Run adcfgclone 					    #
			#########################################
			echo "START TASK: $step start_rman_prod_backups"
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Start $srcappname new backups"
			echo $now >>$logfilepath$logfilename
			#
			echo taring ${apphomepath} to ${appbkupdir}${srcappname}.tar.gz
			apps_run_adcfgclone 
			rcode=$?
			if [ $? -ne 0 ] # if RMAN connection fails
			then
				error_notification_exit $rcode "Apps clone for $trgappname FAILED!!" $trgappname $step
			fi
			echo "END   TASK: $step os_tar_gz_file"
		;;
#		"250")
			########################################
			#  Source database backups completed   #
			########################################
			#
			########################################
			#  check source apps after backups #
			########################################
		"300")
            echo "START TASK: $step end-of $srcappname app backup"
            syncpoint $srcappname "0 " "$LINENO"
            echo "END   TASK: $step end-of $srcappname app backup"
		;;
        *)
            echo "step not found - step: $step around Line ===> "  "$LINENO"
        ;;
        esac
done

