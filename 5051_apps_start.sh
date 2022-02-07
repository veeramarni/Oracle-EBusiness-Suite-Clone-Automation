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
. ${functionbasepath}/error_notification_exit.sh
. ${functionbasepath}/get_decrypted_password.sh
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