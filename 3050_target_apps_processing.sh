#!/bin/bash
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
abendfile="$trgbasepath""$trgappname"/"$trgappname"_3050_abend_step"$2"
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
. ${functionbasepath}/appschangepassword.sh
. ${custfunctionbasepath}/appspostclonesteps$trgappname.sh
#
########################################
#       VALIDATIONS                    #
########################################
#
if [ $# -lt 3 ]
then
	echo " ====> Abort!!!. Invalid apps arguments for overlay"
        usage $0 :1000_overlay_staging  "[APPS NAME] [TIER NO 1..3] Y/N/C(paratial[N] / full[Y] / conig only(C)/ start only(S))"
        ########################################################################
        #   send notification  and exit                                        #
        ########################################################################
        send_notification "$trgappname"_Overlay_abend "Invalid arguments for replication" ${TOADDR} ${RTNADDR} ${CCADDR}
        exit 3
fi
#
unset tier
tier=$2
unset clonetype
clonetype=$3
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
if [[ ! -n "${context_file+1}" || -z "${context_file}" ]]
then 
   echo "CONTEXT_FILE cannot be empty, please set the environment correctly"
   error_notification_exit $rcode "Validation Error:  CONTEXT_FILE variable cannot be empty !!" $trgappname 0 $LINENO
fi
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
trgappspwd=$( get_decrypted_password $trgappspwd )
srcappspwd=$( get_decrypted_password $srcappspwd )
trgdbsystem=$( get_decrypted_password $trgdbsystem )
trgappsysadmin=$( get_decrypted_password $trgappsysadmin )
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
#for step in $(seq "$stepnum" 50 650)
for (( step="$stepnum" ; step<=650; step+=50 ))
do
        case $step in
        "50")
			#####################################################################################
			#  send notification that APPS overlay started                                      #
			#  													                                #
			#####################################################################################
			echo "START   TASK: $step send_notification"
			send_notification "$trgappname"_clone_started  "$trgappname cloning started" ${TOADDR} ${RTNADDR} ${CCADDR}
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
				echo "			apps process is running.."
				echo "			shutting down apps.."
				. ${apptargethomepath}apps_st/appl/${context_name}.env
				$ADMIN_SCRIPTS_HOME/adstpall.sh  apps/${trgappspwd} >$logfilepath$trgappname_adstpall.log 2>&1
				sleep 50
				if is_os_process_running ${apptargethomepath} 
				then
					echo "			some of the apps process is still running.."
					echo "			killing.."
					os_kill_process_homepath ${apptargethomepath}  >$logfilepath$trgappname_os_kill_process.log 2>&1
					sleep 20
					echo "			Verifying whether any process still running.."
					os_kill_process_homepath ${apptargethomepath}  >$logfilepath$trgappname_os_kill_process.log 2>&1
					sleep 20
				else 
					echo "			apps process is not running.."
				fi
			fi
			_step=$step
			if [[ -n "${clonetype+1}" && ${clonetype} == 'Y' ]]
			then
				echo "~~~~ INFO: Doing full clone"
			elif [[ -n "${clonetype+1}" && ${clonetype} == 'N' ]]
			then
			    echo "~~~~ INFO: Doing partial clone"
				step=200 # Equivalent to step 250
			elif [[ -n "${clonetype+1}" && ${clonetype} == 'C' ]]
			then
				echo "~~~~ INFO: Config full clone, it will not start the apps process or run post steps"
			elif [[ -n "${clonetype+1}" && ${clonetype} == 'S' ]]
			then
				echo "~~~~ INFO: Start apps services only, it will skip all steps and only start apps steps and perform any post steps"
				step=400 # Equivalent to step 450 (start Apps services)
			else 
				echo "~~~~ WARN: argument suppose to be Y or N, so by default it will do full clone"
			fi
			echo "END     TASK: $_step apps status check"
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
			    echo "			deleting apps_st and tech_st.."
				os_delete_move_dir D "${apptargethomepath}/apps_st ${apptargethomepath}/tech_st"
			else 
			    error_notification_exit $rcode "old apps_st and old tech_st directory may not exist." $trgappname $step $LINENO
			fi
			#
	        rcode=$?
            if [ "$rcode" -gt 0 ]
            then
				error_notification_exit $rcode "Deleting old apps directories was FAILED due to error!!" $trgappname $step $LINENO
			fi
			echo "END     TASK: $step delete_appl_tech_st"
		;; 		
		"200")
			########################################
			#  restore apps from  backup		   #
			########################################
			echo "START   TASK: $step os_untar_gz_file"
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Untar $srcappname from backups"
			echo $now >>$logfilepath$logfilename
			#
			if is_os_file_exist ${appsourcebkupdir}${srcappname}${tier}.tar.gz 
			then
			    echo "			restoring ${appsourcebkupdir}${srcappname}${tier}.tar.gz.."
				os_untar_gz_file ${appsourcebkupdir}${srcappname}${tier}.tar.gz ${apptargethomepath}
			else 
			    error_notification_exit $rcode "Apps restore is failed due to missing tar backups." $trgappname $step $LINENO
			fi
			#
	        rcode=$?
            if [ "$rcode" -gt 0 ]
            then
				error_notification_exit $rcode "Apps restore from backups is FAILED due to error!!" $trgappname $step $LINENO
			fi
			echo "END     TASK: $step os_untar_gz_file"
		;; 
		"250")
			#########################################
			#  Run adcfgclone 					    #
			#########################################
			echo "START   TASK: $step apps_run_adcfgclone"
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Start $srcappname clone to $trgappname."
			echo $now >>$logfilepath$logfilename
			#
			echo "			application cloning to $trgappname.."
			if [ "${tier}" -eq 1 ]
			then
				apps_run_adcfgclone "${apptargethomepath}apps_st/comn/clone/bin" ${context_file} ${srcappspwd}
				rcode=$?
			else
				apps_run_adcfgclone "${apptargethomepath}apps_st/comn/clone/bin" ${context_file} ${trgappspwd}
				rcode=$?
			fi
			if [ "$rcode" -ne 0 ]
			then
				error_notification_exit $rcode "Apps clone for $trgappname FAILED during adcfgclone step!!" $trgappname $step $LINENO
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
			echo "			setting apps environment for $trgappname.."
			. ${apptargethomepath}apps_st/appl/${context_name}.env
			. $APPL_TOP/APPS${context_name}.env
			rcode=$?
			if [ "$rcode" -ne 0 ]
			then
				error_notification_exit $rcode "Set Apps enviornment FAILED due to invalid environment files!!" $trgappname $step $LINENO
			fi
			echo "END     TASK: $step set apps environment"
		;;
		"350")
			########################################
			#  Change FND Users password 		   #
			########################################
			echo "START   TASK: $step Change FND Users passwords only when run on TIER 1"
						now=$(date "+%m/%d/%y %H:%M:%S")" ====> Change FND Users passwords."
			echo $now >>$logfilepath$logfilename
			#
			if [ "${tier}" -eq 1 ]
			then
				echo "			changing FND Users passwords for $trgappname.."
				appschangepassword ${srcappspwd} ${trgdbsystem} ${trgappsysadmin} ${trgappspwd}
				rcode=$?
				if [ "$rcode" -ne 0 ]
				then
					error_notification_exit $rcode "Change FND Users passwords FAILED!!" $trgappname $step $LINENO
				fi
			else
				echo "~~~ Skipping this step as it is not TIER 1"
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
			echo "			running apps autoconfig on $trgappname.."
			apps_run_autoconfig  $ADMIN_SCRIPTS_HOME  ${trgappspwd}
			rcode=$?
			if [ "$rcode" -ne 0 ]
			then
				error_notification_exit $rcode "Run AutoConfig on $trgappname FAILED!!" $trgappname $step $LINENO
			fi
			if [[ -n "${clonetype+1}" && ${clonetype} == 'C' ]]
			then
			    echo "~~~~ INFO: Skipping Starting Apps process and post clone steps"
				step=550 # Equivalent to step 600
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
			echo "			starting apps on $trgappname.."
			$ADMIN_SCRIPTS_HOME/adstrtal.sh  apps/${trgappspwd} >$logfilepath$trgappname_adstrtal.log 2>&1
			rcode=$?
			if [ "$rcode" -ne 0 ]
			then
				error_notification_exit $rcode "Starting apps process on $trgappname FAILED!!" $trgappname $step $LINENO
			fi
			echo "END     TASK: $step Start Apps process"
		;;
#		"500")
			########################################
			#  Profile change			 		   #
			########################################
#			echo "START   TASK: $step Change profile properties"
#						now=$(date "+%m/%d/%y %H:%M:%S")" ====> Change profile properties."
#			echo $now >>$logfilepath$logfilename
#			#
#			echo start apps on $trgappname
#			custom_sql_run "" $ORACLE_HOME $trgappname "apps" ${trgappspwd} ${sqlbasepath}/apps_profile_set_sitename.sql ${sitename}
#			custom_sql_run "" $ORACLE_HOME $trgappname "apps" ${trgappspwd} ${sqlbasepath}/apps_profile_set_javacolorscheme.sql ${fnd_color_scheme}
#			rcode=$?
#			if [ "$rcode" -ne 0 ]
#			then
#				error_notification_exit $rcode "Changing apps profile properties on $trgappname FAILED!!" $trgappname $step $LINENO
#			fi
#			echo "END     TASK: $step Change profile properties"
#		;;
		"550")
			########################################
			#  Custom Post Clone steps   		   #
			########################################
			echo "START   TASK: $step Start post clone process"
						now=$(date "+%m/%d/%y %H:%M:%S")" ====> Post clone steps."
			echo $now >>$logfilepath$logfilename
			#
			echo "			executing post clone steps on $trgappname.."
			appspostclonesteps
			rcode=$?
			if [ "$rcode" -ne 0 ]
			then
				error_notification_exit $rcode "Post clone steps on $trgappname FAILED!!" $trgappname $step $LINENO
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
            echo "END     TASK: $step end-of $srcappname app clone"
		;;
        *)
            echo "step not found - step: $step around Line ===> "  "$LINENO"
        ;;
        esac
done

