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
logfilename="$trgdbname"_Overlay_Apps_PART2$(date +%a)"_$(date +%F).log"


####################################################################################################
#      add functions library                                                                       #
####################################################################################################
. ${functionbasepath}/usage.sh    
. ${functionbasepath}/syncpoint.sh   
. ${functionbasepath}/send_notification.sh
. ${functionbasepath}/os_tar_gz_file.sh
. ${functionbasepath}/os_untar_gz_file.sh
. ${functionbasepath}/os_delete_move_file.sh
. ${functionbasepath}/os_delete_move_dir.sh
. ${functionbasepath}/os_user_check.sh
. ${functionbasepath}/os_verify_or_make_directory.sh
. ${functionbasepath}/os_verify_or_make_file.sh
. ${functionbasepath}/is_os_file_exist.sh
. ${functionbasepath}/is_os_dir_exist.sh
. ${functionbasepath}/is_os_process_running.sh
. ${functionbasepath}/os_kill_process_homepath.sh
. ${functionbasepath}/apps_run_adcfgclone.sh
. ${functionbasepath}/apps_run_autoconfig.sh
. ${functionbasepath}/error_notification_exit.sh
. ${functionbasepath}/custom_sql_run.sh
. ${functionbasepath}/get_decrypted_password.sh
. ${custfunctionbasepath}/apps*$trgappname.sh
#
########################################
#       VALIDATIONS                    #
########################################
#
if [ $# -lt 2 ]
then
	echo " ====> Abort!!!. Invalid apps arguments for overlay"
        usage $0 :1000_overlay_staging  "[APPS NAME] [TIER NO 1..3]"
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
trgappspwd=get_decrypted_password trgappspwd
srcappspwd=get_decrypted_password srcappspwd
echo "password for trg $trgappspwd"
echo "password for src $srcappspwd"
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
for step in $(seq "$stepnum" 50 650)
do
        case $step in
        "50")
			#####################################################################################
			#  send notification that APPS overlay started                                      #
			#  													                                #
			#####################################################################################
			echo "START   TASK: $step send_notification"
			send_notification "$srcappname"_backup_started  "$srcappname backup started" ${TOADDR} ${RTNADDR} ${CCADDR}
			#
			########################################
			#  write an audit record in the log    #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Send start $srcappname apps backup Notification"
			echo $now >>$logfilepath$logfilename
			#
			echo "END     TASK: $step send_notification"
		;;
		"100")
			########################################
			#  check source apps status            #
			########################################
			echo "START   TASK: $step apps status check"
			if is_os_process_running ${apptargethomepath} 
			then
				echo "Apps process is running.."
				. ${apptargethomepath}apps_st/appl/$trgappname*.env
				$ADMIN_SCRIPTS_HOME/adstpall.sh  apps/${trgappspwd}
				sleep 100
				if is_os_process_running ${apptargethomepath} 
				then
					echo "Some of the apps process is still running.."
					os_kill_process_homepath ${apptargethomepath} 
				else 
					echo "Apps process is not running.."
				fi
			fi
			echo "END     TASK: $step apps status check"
		;;
		"150")
			########################################
			#  Clean old apps home				   #
			########################################
			echo "START   TASK: $step delete_appl_tech_st"
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
				os_delete_move_dir D "${apptargethomepath}/apps_st ${apptargethomepath}/tech_st"
			else 
			    error_notification_exit $rcode "Apps Backup not found." $trgappname $step $LINENO
			fi
			#
	        rcode=$?
            if [ "$rcode" -gt 0 ]
            then
				error_notification_exit $rcode "Restore apps files FAILED!!" $trgappname $step $LINENO
			fi
			echo "END     TASK: $step delete_appl_tech_st"
		;; 		
		"200")
			########################################
			#  restore apps from  backup		   #
			########################################
			echo "START   TASK: $step os_untar_gz_file"
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
			echo "END     TASK: $step os_untar_gz_file"
		;; 
		"250")
			#########################################
			#  Run adcfgclone 					    #
			#########################################
			echo "START   TASK: $step apps_run_adcfgclone"
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Start $srcappname cloning.s"
			echo $now >>$logfilepath$logfilename
			#
			echo application cloning to $trgappname
			apps_run_adcfgclone "${apptargethomepath}apps_st/comn/clone/bin" ${context_file} ${srcappspwd}
			rcode=$?
			if [ "$rcode" -ne 0 ]
			then
				error_notification_exit $rcode "Apps clone for $trgappname FAILED!!" $trgappname $step $LINENO
			fi
			echo "END     TASK: $step apps_run_adcfgclone"
		;;
		"300")
			########################################
			#  Set new apps environment 		   #
			########################################
			echo "START   TASK: $step set apps environment"
						now=$(date "+%m/%d/%y %H:%M:%S")" ====> Set apps enviroment."
			echo $now >>$logfilepath$logfilename
			#
			echo set apps environment for $trgappname
			. ${apptargethomepath}apps_st/appl/$trgappname*.env
			rcode=$?
			if [ "$rcode" -ne 0 ]
			then
				error_notification_exit $rcode "Set Apps enviornment FAILED!!" $trgappname $step $LINENO
			fi
			echo "END     TASK: $step set apps environment"
		;;
		"350")
			########################################
			#  Change FND Users password 		   #
			########################################
			echo "START   TASK: $step Change FND Users passwords"
						now=$(date "+%m/%d/%y %H:%M:%S")" ====> Change FND Users passwords."
			echo $now >>$logfilepath$logfilename
			#
			echo Change FND Users passwords for $trgappname
			appschangepassword ${srcappspwd} ${trgappspwd}
			rcode=$?
			if [ "$rcode" -ne 0 ]
			then
				echo "Skipping verification"
#				error_notification_exit $rcode "Change FND Users passwords!!" $trgappname $step $LINENO
			fi
			echo "END     TASK: $step Change FND Users passwords"
		;;
		"400")
			########################################
			#  Run Autoconfig			 		   #
			########################################
			echo "START   TASK: $step run auto config"
						now=$(date "+%m/%d/%y %H:%M:%S")" ====> Run Apps AutoConfig."
			echo $now >>$logfilepath$logfilename
			#
			echo run apps autoconfig on $trgappname
			apps_run_autoconfig  $ADMIN_SCRIPTS_HOME  ${trgappspwd}
			rcode=$?
			if [ "$rcode" -ne 0 ]
			then
				error_notification_exit $rcode "Run AutoConfig on $trgappname FAILED!!" $trgappname $step $LINENO
			fi
			echo "END     TASK: $step run auto config"
		;;
		"450")
			########################################
			#  Start Apps				 		   #
			########################################
			echo "START   TASK: $step Start Apps process"
						now=$(date "+%m/%d/%y %H:%M:%S")" ====> Start Apps Process."
			echo $now >>$logfilepath$logfilename
			#
			echo start apps on $trgappname
			$ADMIN_SCRIPTS_HOME/adstrtal.sh  apps/${trgappspwd}
			rcode=$?
			if [ "$rcode" -ne 0 ]
			then
				error_notification_exit $rcode "Starting apps process on $trgappname FAILED!!" $trgappname $step $LINENO
			fi
			echo "END     TASK: $step Start Apps process"
		;;
		"500")
			########################################
			#  Profile change			 		   #
			########################################
			echo "START   TASK: $step Change profile properties"
						now=$(date "+%m/%d/%y %H:%M:%S")" ====> Change profile properties."
			echo $now >>$logfilepath$logfilename
			#
			echo start apps on $trgappname
			custom_sql_run "" $ORACLE_HOME $trgappname "apps" ${trgappspwd} ${sqlbasepath}/apps_profile_set_sitename.sql ${sitename}
			rcode=$?
			if [ "$rcode" -ne 0 ]
			then
				error_notification_exit $rcode "Changing apps profile properties on $trgappname FAILED!!" $trgappname $step $LINENO
			fi
			echo "END     TASK: $step Change profile properties"
		;;
		"550")
			########################################
			#  Custom Post Clone steps   		   #
			########################################
			echo "START   TASK: $step Start post clone process"
						now=$(date "+%m/%d/%y %H:%M:%S")" ====> Post clone steps."
			echo $now >>$logfilepath$logfilename
			#
			echo executing post clone steps on $trgappname
			appspostclonesteps
			rcode=$?
			if [ "$rcode" -ne 0 ]
			then
				error_notification_exit $rcode "Starting apps process on $trgappname FAILED!!" $trgappname $step $LINENO
			fi
			echo "END     TASK: $step post clone process"
		;;
		"600")
			echo "START   TASK: " $step "send_notification"
			########################################################################
			#   send notification that target apps overlay has been completed	   #
			########################################################################
			send_notification "$trgappname Apps Overlay completed" "$trgappname overlay has been completed" ${TOADDR} ${RTNADDR} ${CCADDR}
			#	
			echo "END     TASK: " $step "send_notification"
		;;
		"650")
            echo "START   TASK: $step end-of $srcappname app backup"
            syncpoint $srcappname "0 " "$LINENO"
            echo "END     TASK: $step end-of $srcappname app backup"
		;;
        *)
            echo "step not found - step: $step around Line ===> "  "$LINENO"
        ;;
        esac
done

