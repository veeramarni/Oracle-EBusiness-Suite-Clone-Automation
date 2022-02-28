#!/bin/bash
#
####################################################################################################
#               S T A G I N G   O V E R L A Y  - staging task                                      #
####################################################################################################
#                        2000_target_processing.sh                                                  #
#                                                                                                  #
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
customxmlbasepath="${custfunctionbasepath}xml/"
sqlbasepath="${functionbasepath}sql/"
rmanbasepath="${functionbasepath}rman/"
abendfile="$trgbasepath""$trgdbname"/"$trgdbname"_2000_abend_step
logfilename="$trgdbname"_DB_Overlay_$(date +%a)"_$(date +%F).log"

####################################################################################################
#																								   #
#       STOP MODIFYING BELOW CODE!!!															   #
#																								   #
####################################################################################################
#      add functions library                                                                       #
####################################################################################################
. ${functionbasepath}/usage.sh
. ${functionbasepath}/dir_empty.sh        
. ${functionbasepath}/syncpoint.sh        
. ${functionbasepath}/io_calibrate.sh     
. ${functionbasepath}/purge_audit.sh      
. ${functionbasepath}/turn_cluster_off.sh 
. ${functionbasepath}/turn_cluster_on.sh 
. ${functionbasepath}/set_database_audit.sh
. ${functionbasepath}/delete_rman_archivelogs_backups_all.sh
. ${functionbasepath}/stop_database_sqlplus.sh 
. ${functionbasepath}/start_database_sqlplus.sh 
. ${functionbasepath}/send_notification.sh
. ${functionbasepath}/check_database_status1.sh
. ${functionbasepath}/check_database_status2.sh
. ${functionbasepath}/delete_sourcedb_backups.sh
. ${functionbasepath}/start_mount_database_sqlplus.sh
. ${functionbasepath}/start_nomount_database_sqlplus.sh
. ${functionbasepath}/list_database_recover_files.sh
. ${functionbasepath}/alter_database_archivelog_enable.sh
. ${functionbasepath}/alter_database_open_sqlplus.sh
. ${functionbasepath}/start_target_rman_replication_from_backups.sh
. ${functionbasepath}/delete_os_trace_files.sh
. ${functionbasepath}/delete_os_adump_files.sh
. ${functionbasepath}/delete_database_asm_tempfile.sh
. ${functionbasepath}/delete_database_asm_datafiles.sh
. ${functionbasepath}/apps_fnd_clean.sh
. ${functionbasepath}/drop_database.sh
. ${functionbasepath}/custom_sql_run.sh
. ${functionbasepath}/param_db_file_name_convert.sh
. ${functionbasepath}/db_adconfig.sh
. ${functionbasepath}/os_user_check.sh
. ${functionbasepath}/os_verify_or_make_directory.sh
. ${functionbasepath}/os_verify_or_make_file.sh
. ${functionbasepath}/error_notification_exit.sh
. ${functionbasepath}/get_decrypted_password.sh
. ${functionbasepath}/copy_file.sh
. ${functionbasepath}/db_rename_pdb_sqlplus.sh
. ${functionbasepath}/db_update_adlib.sh
. ${functionbasepath}/setup_util_file_directories.sh
#
#
########################################
#      Validations                     #
########################################
#
if [ $# -lt 1 ]
then
	echo ""
	echo ""
	echo " ====> Abort!!!. Invalid database name for overlay"
        usage $0 :2000_target_processing.sh  "[DATABASE NAME]"
	########################################################################
	#   send notification                                                  #
	########################################################################
	send_notification "$trgdbname"_Overlay_abend "Invalid target $trgdbname database" ${TOADDR} ${RTNADDR} ${CCADDR}
        exit 3
fi

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
if [[ ! -n "${context_file+1}" || -z "${context_file}" ]]
then 
   echo "CONTEXT_FILE cannot be empty, please set the environment correctly"
   error_notification_exit $rcode "Validation Error:  CONTEXT_FILE variable cannot be empty !!" $trgdbname 0 $LINENO
fi
#
trgappspwd=$( get_decrypted_password $trgappspwd )
srcappspwd=$( get_decrypted_password $srcappspwd )
srcdbsystem=$( get_decrypted_password $srcdbsystem )
trgdbsystem=$( get_decrypted_password $trgdbsystem )
#####################################################################
#                                                                   #
# Write an block condition to stop running the job with condition   #
#                                                                   #
#####################################################################

#####################################################################
#  End of code that prevents the job from running before 10:00pm    #
#                                                                   # 
#                                                                   # 
#####################################################################
#

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
echo $now >>${logfilepath}${logfilename}
#
now=$(date "+%m/%d/%y %H:%M:%S")" ====  ########  $srcdbname to $trgdbname replication stage has been started  ########"
echo $now >>${logfilepath}${logfilename}
#
for step in $(seq "$stepnum" 50 1650)
do
        case $step in
        "50")
			echo "START   TASK: " $step "dir_empty"
			########################################
			#  update log file:                    #
			#  check backup directory              #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> check $srcdbname database backup directory"
			echo $now >>${logfilepath}${logfilename}
			#
			dir_empty $dbsourcebkupdir
			#
			rcode=$?
			if [ "$rcode" -gt 0 ]
			then
				error_notification_exit $rcode "Backup folder for ${srcdbname} does not exists or folder is empty." $trgdbname $step $LINENO
			fi
			echo "END     TASK: " $step "dir_empty"
        ;;
        "100")
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
			if [ "$rcode" -gt 0 ]
			then
				error_notification_exit $rcode "Check database status for $trgdbname failed." $trgdbname $step $LINENO
			fi
			echo "END     TASK: " $step "check_database_status1"
        ;;
        "150")
			echo "START   TASK: " $step "start-oem-blackout"
			########################################
			#  update log file:                    #
			#          OEM database blackout       #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Start $trgdbname OEM Blackout"
			echo $now >>${logfilepath}${logfilename}
			echo "END     TASK: " $step "start-oem-blackout"
                ;;
                "200")
			echo "START   TASK: " $step "send-notification_01"

			########################################################################
			#   send notification to start  target database replication            #
			########################################################################
			send_notification "$trgdbname"_Overlay_DB_staging "Replication of $trgdbname database started" ${TOADDR} ${RTNADDR} ${CCADDR}
			echo "END     TASK: " $step "send-notification_01"
		;;
        "250")
			echo "START   TASK: " $step "send-notification_02"
 			########################################################################
			#   send notification to start  target database OEM blackout           #
			########################################################################
			send_notification "$trgdbname"_Overlay_DB_staging "please note that $trgdbname is under OEM blackout" ${TOADDR} ${RTNADDR} ${CCADDR}
			echo "END     TASK: " $step "send-notification_02"
		;;
        "300")
			echo "START   TASK: " $step "delete_rman_archivelogs"
			#######################################
			#   update log:                       #
			#           delete archive logs       #
			#######################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Delete $trgdb archive logs"
			echo $now >>${logfilepath}${logfilename}
			########################################
			#   update log file:                   #
			#       Delete archive logs            #       
			########################################
			delete_rman_archivelogs_backups_all $trginstname $dbtargethomepath
			#
			rcode=$?
			if [ $rcode -ne 0 ] 
			then
				error_notification_exit $rcode "Delete RMAN archive logs and backups for $trgdbname failed." $trgdbname $step $LINENO
			fi
			echo "END     TASK: " $step "delete_rman_archivelogs_backups_all"
		;;
        "350")				
			echo "START   TASK: " $step "stop_database_sqlplus"
			########################################
			# update log file:                     #
			# STOP target DATABASE                 #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Stop $trgdbname database on all nodes"
			echo $now >>${logfilepath}${logfilename}
			#
			stop_database_sqlplus $trginstname $dbtargethomepath $trgdbname
			rcode=$?
			if [ $rcode -ne 0 ] 
			then
				error_notification_exit $rcode "STOP $trgdb database FAILED!!" $trgdbname $step $LINENO
			fi
			echo "END     TASK: " $step "stop_database_sqlplus"
		;;
        "400")
			echo "START   TASK: " $step "start_mount_database_sqlplus"
			########################################
			# update log file:                     #
			# START MOUNT DATABASE on node1        #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> START $trgdbname database in MOUNT mode"
			echo $now >>${logfilepath}${logfilename}
			#
			start_mount_database_sqlplus $trginstname $dbtargethomepath $trgdbname
			#
			rcode=$?
			if [ $rcode -ne 0 ] 
			then
				error_notification_exit $rcode "START $trgdb database in MOUNT mode FAILED!!" $trgdbname $step $LINENO
			fi
			echo "END     TASK: " $step "start_mount_database_sqlplus"
		;;
        "450")
			echo "START   TASK: " $step "drop_database"
			########################################
			# update log file:                     #
			# Drop Database					       #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Drop database in MOUNT mode"
			echo $now >>${logfilepath}${logfilename}
			#
			drop_database $trginstname $dbtargethomepath $trgdbname
			#
			rcode=$?
			if [ $rcode -ne 0 ] 
			then
				error_notification_exit $rcode "Drop $trgdbname database in MOUNT mode FAILED!!" $trgdbname $step $LINENO
			fi
			echo "END     TASK: " $step "drop_database"
		;;
        "500")
			echo "START   TASK:  $step start_nomount_database_sqlplus"
			########################################
			#  update log file:                    #
			#      start database NOMOUNT          #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Start target Database $trgdbname NOMOUNT"
			echo $now >>${logfilepath}${logfilename}
			#
			start_nomount_database_sqlplus $trginstname $dbtargethomepath $trgdbname
			#
			rcode=$?
			if [ $rcode -ne 0 ] 
			then
				error_notification_exit $rcode "Start database $trgdbname NOMOUNT FAILED!!" $trgdbname $step $LINENO
			fi
			echo "END     TASK: " $step "start_nomount_database_sqlplus"
		;;
		"550")
			echo "START   TASK: " $step "create_spfile"
			########################################
			# update log file:                     #
			# STOP target DATABASE                 #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Change DB parameters for $trgdbname database"
			echo $now >>${logfilepath}${logfilename}
			#
			custom_sql_run $trginstname $trgpdb $dbtargethomepath "" "" "as sysdba" ${sqlbasepath}create_spfile.sql 
			rcode=$?
			if [ $rcode -ne 0 ] 
			then
				error_notification_exit $rcode "Create spfile for $trgdb database FAILED!!" $trgdbname $step $LINENO
			fi
			echo "END     TASK: " $step "create_spfile"
		;;
		"600")				
			echo "START   TASK: " $step "stop_database_sqlplus"
			########################################
			# update log file:                     #
			# STOP target DATABASE                 #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Stop $trgdbname database on all nodes"
			echo $now >>${logfilepath}${logfilename}
			#
			stop_database_sqlplus $trginstname $dbtargethomepath $trgdbname
			rcode=$?
			if [ $rcode -ne 0 ] 
			then
				error_notification_exit $rcode "STOP $trgdb database FAILED!!" $trgdbname $step $LINENO
			fi
			echo "END     TASK: " $step "stop_database_sqlplus"
		;;	
		"650")
			echo "START   TASK:  $step start_nomount_database_sqlplus"
			########################################
			#  update log file:                    #
			#      start database NOMOUNT          #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Start target Database $trgdbname NOMOUNT"
			echo $now >>${logfilepath}${logfilename}
			#
			start_nomount_database_sqlplus $trginstname $dbtargethomepath $trgdbname
			#
			rcode=$?
			if [ $rcode -ne 0 ] 
			then
				error_notification_exit $rcode "Start database $trgdbname NOMOUNT FAILED!!" $trgdbname $step $LINENO
			fi
			echo "END     TASK:  $step start_nomount_database_sqlplus"
		;;
        "700")
			echo "START   TASK: " $step "param_db_file_name_convert"
			########################################
			# update log file:                     #
			# STOP target DATABASE                 #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Change DB parameters for $trgdbname database"
			echo $now >>${logfilepath}${logfilename}
			#
			param_db_file_name_convert $trginstname $dbtargethomepath ${srcdbdisk}/${srcdbname} ${trgdbdisk}/${trgdbname} ${srcdbdisk}/${srcpdb} ${trgdbdisk}/${trgpdb}
			rcode=$?
			if [ $rcode -ne 0 ] 
			then
				error_notification_exit $rcode "Change DB parameters for $trgdb database FAILED!!" $trgdbname $step $LINENO
			fi
			echo "END     TASK: " $step "param_db_file_name_convert"
		;;
        "750")				
			echo "START   TASK: " $step "stop_database_sqlplus"
			########################################
			# update log file:                     #
			# STOP target DATABASE                 #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Stop $trgdbname database on all nodes"
			echo $now >>${logfilepath}${logfilename}
			#
			stop_database_sqlplus $trginstname $dbtargethomepath $trgdbname
			rcode=$?
			if [ $rcode -ne 0 ] 
			then
				error_notification_exit $rcode "STOP $trgdb database FAILED!!" $trgdbname $step $LINENO
			fi
			echo "END     TASK: " $step "stop_database_sqlplus"
		;;		
			#echo "START   TASK: " $step "delete_database_asm_tempfile"
			########################################
			# update log file:                     #
			# Delete Database ASM TEMP file        #
			########################################
			########################################
			# update log file:                     #
			# Delete Database ASM DATA files       #
			########################################

			########################################
			# update log file:                     #
			# Turn database cluster-flag off       # 
			########################################

			########################################
			# update log file:                     #
			# STOP target DATABASE                 #
			########################################

			########################################
			#  update log file:                    #
			#                                      #
			########################################
	    "800")
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Delete xxxxxx for target database $trgdbname"
			echo $now >>${logfilepath}${logfilename}
			#
			#
			echo "END     TASK: " $step "xxxxxxxxxxxxxxxxxxxx"
		;;
        "850")
			echo "START   TASK: " $step "delete_os_trace_files"
			########################################
			#  update log file:                    #
			#      delete OS old trace files       #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Delete old OS trace files for target database $trgdbname"
			echo $now >>${logfilepath}${logfilename}
			#
			delete_os_trace_files $trgdbname
			#
			rcode=$?
			if [ $rcode -ne 0 ] 
			then
				echo "Skipping trace file deletion"
#				error_notification_exit $rcode "Delete OS old database $trgdbname trace files FAILED!!" $trgdbname $step $LINENO
			fi
			echo "END     TASK: " $step "delete_os_trace_files"
		;;
        "900")
			echo "START   TASK: " $step "delete_os_adump_files"
			########################################
			#  update log file:                    #
			#      delete OS old adump files       #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Delete old OS adump files for target database $trgdbname"
			echo $now >>${logfilepath}${logfilename}
			#
			delete_os_adump_files $trgdbname
			#
			rcode=$?
			if [ $rcode -ne 0 ] 
			then
				echo "Skipping Audit log purging"
#				error_notification_exit $rcode "Delete OS old database adump $trgdbname FAILED!!" $trgdbname $step $LINENO
			fi
			echo "END     TASK: " $step "delete_os_adump_files"
		;;
        "950")
			echo "START   TASK: " $step "start_nomount_database_sqlplus"
			########################################
			#  update log file:                    #
			#      start database NOMOUNT          #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Start target Database $trgdbname NOMOUNT"
			echo $now >>${logfilepath}${logfilename}
			#
			start_nomount_database_sqlplus $trginstname $dbtargethomepath $trgdbname
			#
			rcode=$?
			if [ $rcode -ne 0 ] 
			then
				error_notification_exit $rcode "Start database $trgdbname NOMOUNT FAILED!!" $trgdbname $step $LINENO
			fi
			echo "END     TASK: " $step "start_nomount_database_sqlplus"
		;;
        "1000")
			echo "START   TASK: " $step "start_target_rman_replication_from_backups"
			########################################
			#  update log file:                    #
			#  start target database replication   #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Start $trgdbname RMAN replication"
			echo $now >>${logfilepath}${logfilename}
			#
			start_target_rman_replication_from_backups $trginstname $dbtargethomepath $trgdbname ${dbsourcebkupdir}
			#
			rcode=$?
			if [ $rcode -ne 0 ] 
			then
				error_notification_exit $rcode "Start database $trgdbname replication FAILED!!" $trgdbname $step $LINENO
			fi
			echo "END     TASK: " $step "start_target_rman_replication_from_backups"
		;;
        "1050")
			echo "START   TASK: " $step "list_database_recover_files"
			########################################
			#  update log files:                   #
			#      list recover files              #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> List database $trgdbname recover files"
			echo $now >>${logfilepath}${logfilename}
			#
			list_database_recover_files $trginstname $dbtargethomepath
			#
			rcode=$?
			if [ $rcode -ne 0 ] 
			then
				error_notification_exit $rcode "List recover files for $trgdbname FAILED!!" $trgdbname $step $LINENO
			fi
			echo "END     TASK: " $step "list_database_recover_files"
		;;
        "1100")
			echo "START   TASK: " $step "shutdown_database_node1"
			########################################
			#  update log files:                   #
			#      shutdown database node1/sqlplus #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Shutdown database $trgdbname on node1/sqlplus"
			echo $now >>${logfilepath}${logfilename}
			#
			stop_database_sqlplus $trginstname $dbtargethomepath
			#
			rcode=$?
			if [ $rcode -ne 0 ] 
			then
				error_notification_exit $rcode "Shutdown database $trgdbname node1 using SQLPLUS FAILED!!" $trgdbname $step $LINENO
			fi
			echo "END     TASK: " $step "shutdown_database_sqlplus"
		;;
        "1150")
			echo "START   TASK: " $step "start_mount_database_sqlplus"
			########################################
			#  update log file:                    #
			#      start database in mount mode    #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Start database $trgdbname in mount mode"
			echo $now >>${logfilepath}${logfilename}
			#
			start_mount_database_sqlplus $trginstname $dbtargethomepath
			#
			rcode=$?
			if [ $rcode -ne 0 ] 
			then
				error_notification_exit $rcode "Start database $trgdbname in mount mode FAILED!!" $trgdbname $step $LINENO
			fi
			echo "END     TASK: " $step "start_mount_database_sqlplus"
		;;
        "1200")
			echo "START   TASK: " $step "alter_database_archivelog_enable"
			########################################
			#  update log file:                    #
			#      alter database archivelog       #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Alter database $trgdbname archivelog"
			echo $now >>${logfilepath}${logfilename}
			#
			alter_database_archivelog_enable $trginstname $dbtargethomepath
			#
			rcode=$?
			if [ $rcode -ne 0 ] 
			then
				error_notification_exit $rcode "Alter database $trgdbname archivelog FAILED!!" $trgdbname $step $LINENO
			fi
			echo "END     TASK: " $step "alter_database_archivelog_enable"
		;;
        "1250")
			echo "START   TASK: " $step "alter_database_open_sqlplus"
			########################################
			#  update log file:                    #
			#      alter databa open               #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Alter $trgdbname database open using sqlplus"
			echo $now >>${logfilepath}${logfilename}
			#
			alter_database_open_sqlplus $trginstname $dbtargethomepath
			#
			rcode=$?
			if [ $rcode -ne 0 ] 
			then
				error_notification_exit $rcode "Alter database $trgdbname OPEN  FAILED!!" $trgdbname $step $LINENO
			fi
			echo "END     TASK: " $step "alter_database_open_sqlplus"
		;;
		"1300")
			echo "START   TASK: " $step "copy descriptive file"
			########################################
			#  update log file:                    #
			#      copy descriptive file to target #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Copy $trgdbname to DB_HOME"
			echo $now >>${logfilepath}${logfilename}
			#
			copy_file ${customxmlbasepath}${srcpdb}_PDBDesc.xml ${dbtargethomepath}/dbs
			#
			rcode=$?
			if [ $rcode -ne 0 ] 
			then
				error_notification_exit $rcode "Copy $trgdbname to DB_HOME  FAILED!!" $trgdbname $step $LINENO
			fi
			echo "END     TASK: " $step "copy_file"
		;;
		"1350")
			echo "START   TASK: " $step "rename pdb from source to target"
			########################################
			#  update log file:                    #
			#      rename pdb                      #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Rename pdb $trgpdb to $srcpdb using sqlplus"
			echo $now >>${logfilepath}${logfilename}
			#
			db_rename_pdb_sqlplus $trginstname $dbtargethomepath $srcpdb $trgpdb
			#
			rcode=$?
			if [ $rcode -ne 0 ] 
			then
				error_notification_exit $rcode "Rename pdb $trgpdb to $srcpdb FAILED!!" $trgdbname $step $LINENO
			fi
			echo "END     TASK: " $step "db_rename_pdb_sqlplus"
		;;
		"1400")
			echo "START   TASK: " $step "setup util file directories"
			########################################
			#  update log file:                    #
			#      rename pdb                      #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Setup util file directories usign perl"
			echo $now >>${logfilepath}${logfilename}
			#
			setup_util_file_directories $trgpdb $dbtargethomepath $context_file $srcappspwd $srcdbsystem
			#
			rcode=$?
			if [ $rcode -ne 0 ] 
			then
				error_notification_exit $rcode "Setup util file directories usign perl FAILED!!" $trgdbname $step $LINENO
			fi
			echo "END     TASK: " $step "setup_util_file_directories"
		;;
		"1450")
			echo "START   TASK: " $step "update db libraries"
			########################################
			#  update log file:                    #
			#      rename pdb                      #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Update DB Libraries using sqlplus"
			echo $now >>${logfilepath}${logfilename}
			#
			db_update_adlib $trginstname $dbtargethomepath $trgpdb
			#
			rcode=$?
			if [ $rcode -ne 0 ] 
			then
				error_notification_exit $rcode "Update DB Libraries using sqlplus FAILED!!" $trgdbname $step $LINENO
			fi
			echo "END     TASK: " $step "db_update_adlib"
		;;
			########################################
			#  update log file:                    #
			#      set database audit              #
			########################################

			########################################
			#  update log files:                   #
			#      shutdown database node1/sqlplus #
			########################################

			########################################
			#  update log files:                   #
			#      start database rac on all nodes #
			########################################

			########################################
			#  update log file: 				   #
			#        REFRRESH post scripts         #
			########################################
		"1500")
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Execute $trgdbname REFRESH Post Scripts"
			echo $now >>${logfilepath}${logfilename}
			#
			echo "START   TASK: " $step "apps_fnd_clean"
			apps_fnd_clean $trginstname $trgpdb $dbtargethomepath
			#
			rcode=$?
			if [ $rcode -ne 0 ] 
			then
				error_notification_exit $rcode "Post scripts (FND_CLEAN) on $trgdbname are  FAILED!!" $trgdbname $step $LINENO
			fi
			echo "END     TASK: " $step "REFRESH_post_scripts"
		;;
        "1550")
			########################################
			#  update log file:                    #
			#        Any post scripts              #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Execute $trgdbname REFRESH Post Scripts"
			echo $now >>${logfilepath}${logfilename}
			#
			echo "START   TASK: " $step "custom_sql_run postsqlexecution$trgdbname"
			custom_sql_run $trginstname $trgpdb $dbtargethomepath "" "" "as sysdba" ${custsqlbasepath}postsqlexecution$trgdbname.sql ${trgdbsystem}
			#
			rcode=$?
			if [ $rcode -ne 0 ] 
			then
				error_notification_exit $rcode "Post scripts sql on $trgdbname are  FAILED!!" $trgdbname $step $LINENO
			fi
			echo "END     TASK: " $step "custom_sql_run postsqlexecution$trgdbname"
		;;
		"1600")
		    ########################################
			#  update log file:                    #
			#        Run DB Autoconfig             #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Execute $trgdbname Autoconfig Scripts"
			echo $now >>${logfilepath}${logfilename}
			#
			echo "START   TASK: " $step "db_adconfig"
			db_adconfig $trgpdb $dbtargethomepath $context_file $srcappspwd
			#
			rcode=$?
			if [ $rcode -ne 0 ] 
			then
				error_notification_exit $rcode "Autoconfig run for $trgdbname is  FAILED!!" $trgdbname $step $LINENO
			fi
			echo "END     TASK: " $step "db_adconfig"
			#
			########################################
			#  update log file:                    #
			#     register database in RMAN        #
			#                                      #
			########################################
			#
			#
			########################################
			#  update log file:                    #
			#       database RMAN backup           #
			########################################
			#
			#
			########################################
			#  update log file:                    #
			#                                      #
			########################################
			echo "END     TASK: xxxxxxxxxxxxxxxxxxxxxxxx"
		;;
        "1650")
			echo "START   TASK: " $step "send_notification"
			########################################################################
			#   send notification that target database overlay has been completed  #
			########################################################################
			send_notification "$trgdbname"_Overlay_DB_staging_completed "$trgdbname overlay DB refresh has been completed" ${TOADDR} ${RTNADDR} ${CCADDR}
			#	
			echo "END     TASK: " $step "send_notification"
		;;
        "1700")
			echo "START   TASK: " $step "end-of $trgdbname database refresh"
			syncpoint $trgdbname "0 " "$LINENO"
			echo "END     TASK: " $step "end-of $trgdbname database refresh"
		;;
        *)
            echo "step not found - step: $step around Line ===> " "$LINENO"
        ;;
        esac
done
