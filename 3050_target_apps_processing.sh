#!/usr/bin/ksh
#
#####################################################################################################
#                S T A G I N G    O V E R L A Y - target Apps Tasks                            		#
#                           3050_target_apps_processing.sh											#
#####################################################################################################
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
abendfile="$trgbasepath""$trgappname"/"$trgappname"_3050_abend_step


####################################################################################################
#      add functions library                                                                       #
####################################################################################################
    
. ${functionbasepath}/syncpoint.sh   
. ${functionbasepath}/send_notification.sh
. ${functionbasepath}/os_tar_gz_file.sh
. ${functionbasepath}/os_delete_move_file.sh
. ${functionbasepath}/os_delete_move_dir.sh
. ${functionbasepath}/os_user_check.sh
. ${functionbasepath}/os_verify_or_make_directory.sh
. ${functionbasepath}/os_verify_or_make_file.sh
. ${functionbasepath}/is_os_file_exist.sh
. ${functionbasepath}/is_os_dir_exist.sh
. ${functionbasepath}/is_os_process_running.sh
. ${custfunctionbasepath}/error_notification_exit.sh
#
########################################
#       VALIDATIONS                    #
########################################
#
if [ $# -lt 2 ]
then
	echo " ====> Abort!!!. Invalid apps arguments for overlay"
        usage $0 :1000_overlay_staging  "[APPS NAME] [TIER NO]"
        ########################################################################
        #   send notification  and exit                                        #
        ########################################################################
        send_notification "$trgappname"_Overlay_abend "Invalid apps name for replication" ${TOADDR} ${RTNADDR} ${CCADDR}
        exit 3
fi
#
unset tier
tier=$2
#
# Check user  
#
os_user_check ${appsosuser}
	rcode=$?
	if [ "$rcode" -gt 0 ]
	then
		error_notification_exit $rcode "Wrong os user, user should be ${appsosuser}!!" $trgappname 0 $LINENO
	fi
#
# Validate Directory
#
os_verify_or_make_directory ${logfilepath}
os_verify_or_make_directory ${trgbasepath}
os_verify_or_make_directory ${trgbasepath}${srcappname}
os_verify_or_make_file ${abendfile} 0

#
# Verify Apps environment
#
if [[ -n "${TWO_TASK+1}" && $TWO_TASK == $trgappname ]]
then
	echo "Environment is correct!"
else 
	echo "Environment is not set or wrong environment to clone."
	error_notification_exit $rcode "Wrong Enviornment to clone $trgappname !!" $trgappname 0 $LINENO
fi
############################################################
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
for step in $(seq "$stepnum" 50 350)
do
        case $step in
        "50")
			#####################################################################################
			#  send notification that APPS overlay started                                      #
			#  													                                #
			#####################################################################################
			echo "START TASK: $step send_notification"
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
#				os_killall_process FNDLIBR -- Kills all the process which can kill other EBS's FNDLIBR
				 error_notification_exit $rcode "Old Apps processor still running, need clean up. Failed!!" $trgappname $step $LINENO
			else 
				echo "Concurrent process is not running.."
			fi
			echo "END   TASK: $step apps status check"
		;;
		"150")
			########################################
			#  Clean old apps home				   #
			########################################
			echo "START TASK: $step delete_appl_tech_st"
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Delete appl_st tech_st of $trgappname "
			echo $now >>$logfilepath$logfilename
			#
		    if ! is_os_file_exist ${appsourcebkupdir}${srcappname}${tier}.tar.gz 
			then
			    error_notification_exit $rcode "Apps restore is failed due to missing tar backups." $trgappname $step $LINENO
			fi
			if is_os_dir_exist ${apptargethomepath}/apps_st && is_os_dir_exist ${apptargethomepath}/tech_st
			then
			    echo "Deleting apps_st and tech_st"
				os_delete_move_dir D "apps_st tech_st"
			else 
			    error_notification_exit $rcode "Apps Backup not found." $trgappname $step $LINENO
			fi
			#
	        rcode=$?
            if [ "$rcode" -gt 0 ]
            then
				error_notification_exit $rcode "Restore apps files FAILED!!" $trgappname $step $LINENO
			fi
			echo "END   TASK: $step delete_appl_tech_st"
		;; 		
		"200")
			########################################
			#  restore apps from  backup		   #
			########################################
			echo "START TASK: $step os_untar_gz_file"
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Delete $srcappname old backups"
			echo $now >>$logfilepath$logfilename
			#
			if is_os_file_exist ${appsourcebkupdir}${srcappname}${tier}.tar.gz 
			then
			    echo "Restoring ${appsourcebkupdir}${srcappname}${tier}.tar.gz "
				os_untar_gz_file ${appsourcebkupdir}${srcappname}${tier}.tar.gz ${apptargethomepath}
			else 
			    error_notification_exit $rcode "Apps restore is failed due to missing tar backups." $trgappname $step $LINENO
			fi
			#
	        rcode=$?
            if [ "$rcode" -gt 0 ]
            then
				error_notification_exit $rcode "Apps restore is FAILED!!" $trgappname $step $LINENO
			fi
			echo "END   TASK: $step os_untar_gz_file"
		;; 
		"250")
			#########################################
			#  Run adcfgclone 					    #
			#########################################
			echo "START TASK: $step start_rman_prod_backups"
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Start $srcappname new backups"
			echo $now >>$logfilepath$logfilename
			#
			echo taring ${appsourcehomepath} to ${appsourcebkupdir}${srcappname}${tier}.tar.gz
			apps_run_adcfgclone 
			rcode=$?
			if [ "$rcode" -ne 0 ]
			then
				error_notification_exit $rcode "Apps clone for $trgappname FAILED!!" $trgappname $step $LINENO
			fi
			echo "END   TASK: $step os_tar_gz_file"
		;;
#		"300")
			########################################
			#  Source database backups completed   #
			########################################
			#
			########################################
			#  check source apps after backups #
			########################################
		"350")
            echo "START TASK: $step end-of $srcappname app backup"
            syncpoint $srcappname "0 " "$LINENO"
            echo "END   TASK: $step end-of $srcappname app backup"
		;;
        *)
            echo "step not found - step: $step around Line ===> "  "$LINENO"
        ;;
        esac
done

