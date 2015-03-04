#!/bin/bash
#
####################################################################################################
#               S T A G I N G   O V E R L A Y  - staging task                                      #
####################################################################################################
#                        2000_overlay_staging2.sh                                                  #
#                                                                                                  #
####################################################################################################
#
asmsid="+ASM"
asmhomepath="/u01/grid/product/11.2.0/grid/"
bkupbasepath="/orabackup/rmanbackups/"
basepath="/home/oracle/script/script/CLONE_SCRIPTS/"
dbhomepath="/u01/oracle/CONV9EBS/db/tech_st/11.2.0.4/"
trgbasepath="${basepath}targets/"
logfilepath="${basepath}logs/"
functionbasepath="${basepath}function_lib/"
custfunctionbasepath="${basepath}custom_lib/"
custsqlbasepath="${custfunctionbasepath}sql"
sqlbasepath="${functionbasepath}sql/"
rmanbasepath="${functionbasepath}rman/"


#
####################################################################################################
#      add functions library                                                                       #
####################################################################################################
. ${basepath}function_lib/usage.sh
. ${basepath}function_lib/dir_empty.sh        
. ${basepath}function_lib/syncpoint.sh        
. ${basepath}function_lib/user_pwd_reset.sh   
. ${basepath}function_lib/its_crt_users.sh   
. ${basepath}function_lib/crt_directories.sh      
. ${basepath}function_lib/crt_dblinks.sh      
. ${basepath}function_lib/io_calibrate.sh     
. ${basepath}function_lib/audit_settings.sh   
. ${basepath}function_lib/purge_audit.sh      
. ${basepath}function_lib/turn_cluster_off.sh 
. ${basepath}function_lib/turn_cluster_on.sh 
. ${basepath}function_lib/set_database_audit.sh
. ${basepath}function_lib/delete_rman_archivelogs_backups_all.sh
. ${basepath}function_lib/stop_database_sqlplus.sh 
. ${basepath}function_lib/start_database_sqlplus.sh 
. ${basepath}function_lib/send_notification.sh
. ${basepath}function_lib/start_rman_tst_backup.sh
. ${basepath}function_lib/check_database_status1.sh
. ${basepath}function_lib/check_database_status2.sh
. ${basepath}function_lib/delete_sourcedb_backups.sh
. ${basepath}function_lib/start_mount_database_sqlplus.sh
. ${basepath}function_lib/start_nomount_database_sqlplus.sh
. ${basepath}function_lib/rman_register_database.sh
. ${basepath}function_lib/list_database_recover_files.sh
. ${basepath}function_lib/alter_database_archivelog_enable.sh
. ${basepath}function_lib/alter_database_open_sqlplus.sh
. ${basepath}function_lib/start_rman_tst_backup.sh
. ${basepath}function_lib/start_target_rman_replication_from_backups.sh
. ${basepath}function_lib/delete_os_trace_files.sh
. ${basepath}function_lib/delete_os_adump_files.sh
. ${basepath}function_lib/delete_database_asm_tempfile.sh
. ${basepath}function_lib/delete_database_asm_datafiles.sh
. ${basepath}function_lib/apps_fnd_clean.sh
. ${basepath}function_lib/drop_database.sh
. ${basepath}function_lib/custom_sql_run.sh
. ${basepath}function_lib/param_db_file_name_convert.sh
. ${basepath}function_lib/db_adconfig.sh

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
        usage $0 :2000_overlay_staging2  "[DATABASE NAME]"
	########################################################################
	#   send notification                                                  #
	########################################################################
	send_notification "$trgdbname"_Overlay_abend "Invalid target $trgdbname database" 3
        exit 3
fi
#
trgdbname=$1
trgdbname=${trgdbname// }
# To convert dbname to UPPER case
#trgdbname=`echo "$trgdbname" | tr [a-z] [A-Z]`
# 
case $trgdbname in
	"CONV9EBS")
		logfilename="$trgdbname"_Overlay_$(date +%a)"_$(date +%F).log"
		srcdbname="PRODEBS"
		instname="CONV9EBS"
		bkupdir=$bkupbasepath"PRODEBS"
		;;
	*)
		echo ""
		echo ""
		echo " ====> Abort!!!. Invalid staging database name"
		echo ""
		########################################################################
		#   send notification                                                  #
		########################################################################
		send_notification "$trgdbname"_Overlay_abend "Invalid target $trgdbname database" 3
		exit 4
		;;
esac
#
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
abendfile="$trgbasepath""$trgdbname"/"$trgdbname"_abend_step
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
		echo "   SCRIPT LOCATION: ${basepath}2000_overlay_staging2.sh"
                echo "TASK LOG  LOCATION: ${trgbasepath}${trgdbname}/"
                echo " RUN LOG  LOCATION: ${basepath}logs/"
		echo ""
	else
		echo ""
                echo "   NORMAL LOCATION: "$stepnum" ,line: "$linenum""
		echo "   SCRIPT LOCATION: ${basepath}2000_overlay_staging2.sh"
                echo "TASK LOG  LOCATION: ${trgbasepath}${trgdbname}/"
                echo " RUN LOG  LOCATION: ${basepath}logs/"
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
			echo "START TASK: " $step "dir_empty"
			########################################
			#  update log file:                    #
			#  check backup directory              #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> check $srcdbname database backup directory"
			echo $now >>${logfilepath}${logfilename}
			#
			dir_empty $bkupdir
			#
			rcode=$?
			if [ "$rcode" -gt 0 ]
			then
				echo "Backup folder for ${srcdbname} does not exists or folder is empty. \
						Abort!!! RC=" "$rcode"
				########################################
				#  update log file                     #
				########################################
				now=$(date "+%m/%d/%y %H:%M:%S")" ====> Backup folder for ${srcdbname} does \
					not exist or folder is empty. Abort!! RC=""$rcode"       
				echo $now >>${logfilepath}${logfilename}
				syncpoint $trgdbname $step "$LINENO"
				echo "error.......Exit."
				########################################################################
				#   send notification                                                  #
				########################################################################
				send_notification "$trgdbname"_Overlay_abend "Backup folder for $srcdbname is empty" 3
				echo ""
				exit $step
			fi
			echo "END   TASK: " $step "dir_empty"
                ;;
                "100")
			echo "START TASK: " $step "check_database_status1"
			########################################
			#  update log file:                    #
			#          check  DB status            #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Check $trgdbname status on node1"       
			echo $now >>${logfilepath}${logfilename}
			#
			check_database_status1 $instname $dbhomepath
			#
			rcode=$?
			if [ "$rcode" -gt 0 ]
			then
				echo "Check database "$trgdbname" failed. Abrt!!! RC=" "$rcode"
				########################################
				#  update log file                     #
				########################################
				now=$(date "+%m/%d/%y %H:%M:%S")" ====> Check database ${srcdbname} failed. Abort!! \
						RC=""$rcode"       
				echo $now >>${logfilepath}${logfilename}
				syncpoint $trgdbname $step "$LINENO"
				########################################################################
				#   send notification                                                  #
				########################################################################
				send_notification "$trgdbname"_Overlay_abend "Check database status for $trgdbname" 3
				echo "error.......Exit."
				echo ""
				exit $step
			fi
			echo "END   TASK: " $step "check_database_status1"
                ;;
                "150")
			echo "START TASK: " $step "start-oem-blackout"
			########################################
			#  update log file:                    #
			#          OEM database blackout       #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Start $trgdbname OEM Blackout"
			echo $now >>${logfilepath}${logfilename}
			echo "END   TASK: " $step "start-oem-blackout"
                ;;
                "200")
			echo "START TASK: " $step "send-notification_01"

			########################################################################
			#   send notification to start  target database replication            #
			########################################################################
			send_notification "$trgdbname"_Overlay_staging "Replication of $trgdbname database started" 3
			echo "END   TASK: " $step "send-notification_01"
		;;
                "250")
			echo "START TASK: " $step "send-notification_02"
 
			########################################################################
			#   send notification to start  target database OEM blackout           #
			########################################################################
			send_notification "$trgdbname"_Overlay_staging "please note that $trgdbname is under OEM blackout" 3
			echo "END   TASK: " $step "send-notification_02"
		;;
        "300")
			echo "START TASK: " $step "delete_rman_archivelogs"
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
			delete_rman_archivelogs_backups_all $instname $dbhomepath
			#
			rcode=$?
			if [ $rcode -ne 0 ] 
			then
				now=$(date "+%m/%d/%y %H:%M:%S")" ====> Delete $trgdb RMAN archive logs and backups FAILED!!" RC=$rcode
				echo $now >>${logfilepath}${logfilename}
				syncpoint $trgdbname $step "$LINENO"
				########################################################################
				#   send notification                                                  #
				########################################################################
				send_notification "$trgdbname"_Overlay_abend "Delete RMAN archive logs and backups for $trgdbname failed" 3
				echo ""
				exit $step
			fi
			echo "END   TASK: " $step "delete_rman_archivelogs_backups_all"

		;;
        "350")				
			echo "START TASK: " $step "stop_database_sqlplus"
			########################################
			# update log file:                     #
			# STOP target DATABASE                 #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Stop $trgdbname database on all nodes"
			echo $now >>${logfilepath}${logfilename}
			#
			stop_database_sqlplus $instname $dbhomepath $trgdbname
			rcode=$?
			if [ $rcode -ne 0 ] 
			then
				now=$(date "+%m/%d/%y %H:%M:%S")" ====> STOP $trgdb database FAILED!!" RC=$rcode
				echo $now >>${logfilepath}${logfilename}
				syncpoint $trgdbname $step "$LINENO"
				########################################################################
				#   send notification                                                  #
				########################################################################
				send_notification "$trgdbname"_Overlay_abend "Stop target database $trgdbname failed" 3
				echo "error.......Exit."
				echo ""
				exit $step
			fi
			echo "END   TASK: " $step "stop_database_sqlplus"
		;;
        "400")
			echo "START TASK: " $step "start_mount_database_sqlplus"
			########################################
			# update log file:                     #
			# START MOUNT DATABASE on node1        #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> START $trgdbname database in MOUNT mode"
			echo $now >>${logfilepath}${logfilename}
			#
			start_mount_database_sqlplus $instname $dbhomepath $trgdbname
			#
			rcode=$?
			if [ $rcode -ne 0 ] 
			then
				now=$(date "+%m/%d/%y %H:%M:%S")" ====> START $trgdb database in MOUNT mode FAILED!!" \
						RC=$rcode
				echo $now >>${logfilepath}${logfilename}
				syncpoint $trgdbname $step "$LINENO"
				########################################################################
				#   send notification                                                  #
				########################################################################
				send_notification "$trgdbname"_Overlay_abend "Start database $trgdbname failed"
				echo "error.......Exit."
				echo ""
				exit $step
			fi
			echo "END   TASK: " $step "start_mount_database_sqlplus"
		;;
        "450")
			echo "START TASK: " $step "drop_database"
			########################################
			# update log file:                     #
			# Drop Database					       #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Drop database in MOUNT mode"
			echo $now >>${logfilepath}${logfilename}
			#
			drop_database $instname $dbhomepath $trgdbname
			#
			rcode=$?
			if [ $rcode -ne 0 ] 
			then
				now=$(date "+%m/%d/%y %H:%M:%S")" ====> Drop $trgdbname database in MOUNT mode FAILED!!" \
						RC=$rcode
				echo $now >>${logfilepath}${logfilename}
				syncpoint $trgdbname $step "$LINENO"
				########################################################################
				#   send notification                                                  #
				########################################################################
				send_notification "$trgdbname"_Overlay_abend "Drop database $trgdbname failed"
				echo "error.......Exit."
				echo ""
				exit $step
			fi
			echo "END   TASK: " $step "drop_database"
		;;
        "500")
			echo "START TASK:  $step start_database_nomount"
			########################################
			#  update log file:                    #
			#      start database NOMOUNT          #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Start target Database $trgdbname NOMOUNT"
			echo $now >>${logfilepath}${logfilename}
			#
			start_nomount_database_sqlplus $instname $dbhomepath $trgdbname
			#
			rcode=$?
			if [ $rcode -ne 0 ] 
			then
				now=$(date "+%m/%d/%y %H:%M:%S")" ====> Start database "$trgdbname" NOMOUNT FAILED!!" \
						RC=$rcode
				echo $now >>${logfilepath}${logfilename}
				syncpoint $trgdbname $step "$LINENO"
				########################################################################
				#   send notification                                                  #
				########################################################################
				send_notification "$trgdbname"_Overlay_abend "Start target database $trgdbname failed" 3
				echo "error.......Exit."
				echo ""
				exit $step
			fi
			echo "END   TASK: $step start_nomount_database_sqlplus"
		;;
		"550")
			echo "START TASK: " $step "create_spfile"
			########################################
			# update log file:                     #
			# STOP target DATABASE                 #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Change DB parameters for $trgdbname database"
			echo $now >>${logfilepath}${logfilename}
			#
			custom_sql_run $instname $dbhomepath ${custsqlbasepath}create_spfile.sql ${logfilepath}${instname}_create_spfile.log
			rcode=$?
			if [ $rcode -ne 0 ] 
			then
				now=$(date "+%m/%d/%y %H:%M:%S")" ====> Create spfile for $trgdb database FAILED!!" RC=$rcode
				echo $now >>${logfilepath}${logfilename}
				syncpoint $trgdbname $step "$LINENO"
				########################################################################
				#   send notification                                                  #
				########################################################################
				send_notification "$trgdbname"_Overlay_abend "Create spfile for $trgdbname failed" 3
				echo "error.......Exit."
				echo ""
				exit $step
			fi
			echo "END   TASK: " $step "create_spfile"
		;;
		"600")
			echo "START TASK:  $step start_database_nomount"
			########################################
			#  update log file:                    #
			#      start database NOMOUNT          #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Start target Database $trgdbname NOMOUNT"
			echo $now >>${logfilepath}${logfilename}
			#
			start_nomount_database_sqlplus $instname $dbhomepath $trgdbname
			#
			rcode=$?
			if [ $rcode -ne 0 ] 
			then
				now=$(date "+%m/%d/%y %H:%M:%S")" ====> Start database "$trgdbname" NOMOUNT FAILED!!" \
						RC=$rcode
				echo $now >>${logfilepath}${logfilename}
				syncpoint $trgdbname $step "$LINENO"
				########################################################################
				#   send notification                                                  #
				########################################################################
				send_notification "$trgdbname"_Overlay_abend "Start target database $trgdbname failed" 3
				echo "error.......Exit."
				echo ""
				exit $step
			fi
			echo "END   TASK: $step start_nomount_database_sqlplus"
		;;
        "650")
			echo "START TASK: " $step "param_db_file_name_convert"
			########################################
			# update log file:                     #
			# STOP target DATABASE                 #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Change DB parameters for $trgdbname database"
			echo $now >>${logfilepath}${logfilename}
			#
			param_db_file_name_convert $instname $dbhomepath +DATA/${srcdbname} +DATA/${trgdbname}
			rcode=$?
			if [ $rcode -ne 0 ] 
			then
				now=$(date "+%m/%d/%y %H:%M:%S")" ====> Change DB parameters for $trgdb database FAILED!!" RC=$rcode
				echo $now >>${logfilepath}${logfilename}
				syncpoint $trgdbname $step "$LINENO"
				########################################################################
				#   send notification                                                  #
				########################################################################
				send_notification "$trgdbname"_Overlay_abend "Change DB parameters for $trgdbname failed" 3
				echo "error.......Exit."
				echo ""
				exit $step
			fi
			echo "END   TASK: " $step "param_db_file_name_convert"
		;;
        "700")				
			echo "START TASK: " $step "stop_database_sqlplus"
			########################################
			# update log file:                     #
			# STOP target DATABASE                 #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Stop $trgdbname database on all nodes"
			echo $now >>${logfilepath}${logfilename}
			#
			stop_database_sqlplus $instname $dbhomepath $trgdbname
			rcode=$?
			if [ $rcode -ne 0 ] 
			then
				now=$(date "+%m/%d/%y %H:%M:%S")" ====> STOP $trgdb database FAILED!!" RC=$rcode
				echo $now >>${logfilepath}${logfilename}
				syncpoint $trgdbname $step "$LINENO"
				########################################################################
				#   send notification                                                  #
				########################################################################
				send_notification "$trgdbname"_Overlay_abend "Stop target database $trgdbname failed" 3
				echo "error.......Exit."
				echo ""
				exit $step
			fi
			echo "END   TASK: " $step "stop_database_sqlplus"
		;;		
			#echo "START TASK: " $step "delete_database_asm_tempfile"
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
	    "750")
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Delete xxxxxx for target database $trgdbname"
			echo $now >>${logfilepath}${logfilename}
			#
			#
			echo "END   TASK: $step xxxxxxxxxxxxxxxxxxxx"
		;;
        "800")
			echo "START TASK: $step delete_os_trace_files"
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
				now=$(date "+%m/%d/%y %H:%M:%S")" ====> Delete OS old database "$trgdbname" trace files \
				FAILED!!!" RC=$rcode
				echo $now >>${logfilepath}${logfilename}
#######				syncpoint $trgdbname $step "$LINENO"
				echo "error.......Exit."
				echo ""
#######				exit $step
			fi
			echo "END   TASK: $step delete_os_trace_files"
		;;
        "850")
			echo "START TASK: $step delete_os_adump_files"
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
				now=$(date "+%m/%d/%y %H:%M:%S")" ====> Delete OS old database adump "$trgdbname" \
				FAILED!!" RC=$rcode
				echo $now >>${logfilepath}${logfilename}
#####				syncpoint $trgdbname $step "$LINENO"
				echo "error.......Exit."
				echo ""
#####				exit $step
			fi
			echo "END   TASK: $step delete_os_adump_files"
		;;
        "900")
			echo "START TASK:  $step start_database_nomount"
			########################################
			#  update log file:                    #
			#      start database NOMOUNT          #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Start target Database $trgdbname NOMOUNT"
			echo $now >>${logfilepath}${logfilename}
			#
			start_nomount_database_sqlplus $instname $dbhomepath $trgdbname
			#
			rcode=$?
			if [ $rcode -ne 0 ] 
			then
				now=$(date "+%m/%d/%y %H:%M:%S")" ====> Start database "$trgdbname" NOMOUNT FAILED!!" \
						RC=$rcode
				echo $now >>${logfilepath}${logfilename}
				syncpoint $trgdbname $step "$LINENO"
				########################################################################
				#   send notification                                                  #
				########################################################################
				send_notification "$trgdbname"_Overlay_abend "Start target database $trgdbname failed" 3
				echo "error.......Exit."
				echo ""
				exit $step
			fi
			echo "END   TASK: $step start_nomount_database_sqlplus"
		;;
        "950")
			echo "START TASK: " $step "start_target_rman_replication_from_backups"
			########################################
			#  update log file:                    #
			#  start target database replication   #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Start $trgdbname RMAN replication"
			echo $now >>${logfilepath}${logfilename}
			#
			start_target_rman_replication_from_backups $instname $dbhomepath $trgdbname $srcdbname
			#
			rcode=$?
			if [ $rcode -ne 0 ] 
			then
				now=$(date "+%m/%d/%y %H:%M:%S")" ====> Start database "$trgdbname" replication FAILED!!" \
							RC=$rcode
				echo $now >>${logfilepath}${logfilename}
				syncpoint $trgdbname $step "$LINENO"
				########################################################################
				#   send notification                                                  #
				########################################################################
				send_notification "$trgdbname"_Overlay_abend "Start target databse $trgdbname replication failed" 3
				echo "error.......Exit."
				echo ""
				exit $step
			fi
			echo "END   TASK: " $step "start_target_rman_replication_from_backups"
		;;
        "1000")
			echo "START TASK: $step list_database_recover_files"
			########################################
			#  update log files:                   #
			#      list recover files              #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> List database $trgdbname recover files"
			echo $now >>${logfilepath}${logfilename}
			#
			list_database_recover_files $instname $dbhomepath
			#
			rcode=$?
			if [ $rcode -ne 0 ] 
			then
				now=$(date "+%m/%d/%y %H:%M:%S")" ====> List recover files for "$trgdbname" FAILED!!" \
						RC=$rcode
				echo $now >>${logfilepath}${logfilename}
				syncpoint $trgdbname $step "$LINENO"
				########################################################################
				#   send notification                                                  #
				########################################################################
				send_notification "$trgdbname"_Overlay_abend "List recover files for $trgdbname failed" 3
				echo "error.......Exit."
				echo ""
				exit $step
			fi
			echo "END   TASK: $step list_database_recover_files"
		;;
        "1050")
			echo "START TASK: $step shutdown_database_node1"
			########################################
			#  update log files:                   #
			#      shutdown database node1/sqlplus #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Shutdown database $trgdbname on node1/sqlplus"
			echo $now >>${logfilepath}${logfilename}
			#
			stop_database_sqlplus $instname $dbhomepath
			#
			rcode=$?
			if [ $rcode -ne 0 ] 
			then
				now=$(date "+%m/%d/%y %H:%M:%S")" ====> Shutdown database "$trgdbname" node1 using SQLPLUS \
							FAILED!!" RC=$rcode
				echo $now >>${logfilepath}${logfilename}
				syncpoint $trgdbname $step "$LINENO"
				########################################################################
				#   send notification                                                  #
				########################################################################
				send_notification "$trgdbname"_Overlay_abend "Shutdown target database $trgdbname failed" 3
				echo "error.......Exit."
				echo ""
				exit $step
			fi
			echo "END   TASK: $step shutdown_database_sqlplus"
		;;
        "1100")
			echo "START TASK: " $step "start_mount_database_sqlplus"
			########################################
			#  update log file:                    #
			#      start database in mount mode    #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Start database $trgdbname in mount mode"
			echo $now >>${logfilepath}${logfilename}
			#
			start_mount_database_sqlplus $instname $dbhomepath
			#
			rcode=$?
			if [ $rcode -ne 0 ] 
			then
				now=$(date "+%m/%d/%y %H:%M:%S")" ====> Start database "$trgdbname" in mount \
						mode FAILED!!" RC=$rcode
				echo $now >>${logfilepath}${logfilename}
				syncpoint $trgdbname $step "$LINENO"
				########################################################################
				#   send notification                                                  #
				########################################################################
				send_notification "$trgdbname"_Overlay_abend "Start target database $trgdbname failed" 3
				echo "error.......Exit."
				echo ""
				exit $step
			fi
			echo "END   TASK: $step start_mount_database_sqlplus"
		;;
        "1150")
			echo "START TASK: $step alter_database_archivelog_enable"
			########################################
			#  update log file:                    #
			#      alter database archivelog       #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Alter database $trgdbname archivelog"
			echo $now >>${logfilepath}${logfilename}
			#
			alter_database_archivelog_enable $instname $dbhomepath
			#
			rcode=$?
			if [ $rcode -ne 0 ] 
			then
				now=$(date "+%m/%d/%y %H:%M:%S")" ====> Alter database "$trgdbname" archivelog FAILED!!" \
							RC=$rcode
				echo $now >>${logfilepath}${logfilename}
				syncpoint $trgdbname $step "$LINENO"
				########################################################################
				#   send notification                                                  #
				########################################################################
				send_notification "$trgdbname"_Overlay_abend "Alter target databse $trgdbname archivelog failed" 3
				echo "error.......Exit."
				echo ""
				exit $step
			fi
			echo "END   TASK: $step alter_database_archivelog_enable"
		;;
        "1200")
			echo "START TASK: $step alter_database_open_sqlplus"
			########################################
			#  update log file:                    #
			#      alter databa open               #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Alter $trgdbname database open using sqlplus"
			echo $now >>${logfilepath}${logfilename}
			#
			alter_database_open_sqlplus $instname $dbhomepath
			#
			rcode=$?
			if [ $rcode -ne 0 ] 
			then
				now=$(date "+%m/%d/%y %H:%M:%S")" ====> Alter database "$trgdbname" OPEN  FAILED!!" RC=$rcode
				echo $now >>${logfilepath}${logfilename}
				syncpoint $trgdbname $step "$LINENO"
				########################################################################
				#   send notification                                                  #
				########################################################################
				send_notification "$trgdbname"_Overlay_abend "Alter target database $trgdbname archivelog failed" 3
				echo "error.......Exit."
				echo ""
				exit $step
			fi
			echo "END   TASK: $step alter_database_open_sqlplus"
		;;
			#echo "START TASK: $step turn_cluster_on"
			########################################
			#  update log file:                    #
			#      turn database cluster on        #
			########################################

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
		"1250")
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Execute $trgdbname REFRESH Post Scripts"
			echo $now >>${logfilepath}${logfilename}
			#
			echo "      START TASK: apps_fnd_clean"
			apps_fnd_clean $instname $dbhomepath
			#
			rcode=$?
			if [ $rcode -ne 0 ] 
			then
				now=$(date "+%m/%d/%y %H:%M:%S")" ====> Post scripts (FND_CLEAN) on "$trgdbname" are  FAILED!!" RC=$rcode
				echo $now >>${logfilepath}${logfilename}
				syncpoint $trgdbname $step "$LINENO"
				########################################################################
				#   send notification                                                  #
				########################################################################
				send_notification "$trgdbname"_Overlay_abend "Post scripts (FND_CLEAN) on "$trgdbname" are  failed" 3
				echo "error.......Exit."
				echo ""
				exit $step
			fi
			echo "END   TASK: $step REFRESH_post_scripts"
		;;
        "1400")
			########################################
			#  update log file:                    #
			#        Any post scripts              #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Execute $trgdbname REFRESH Post Scripts"
			echo $now >>${logfilepath}${logfilename}
			#
			echo "      START TASK: custom_sql_run user_pwd_reset"
			custom_sql_run $instname $dbhomepath ${custsqlbasepath}user_pwd_reset.sql ${logfilepath}${instname}_user_pwd_reset.log
			#
			rcode=$?
			if [ $rcode -ne 0 ] 
			then
				now=$(date "+%m/%d/%y %H:%M:%S")" ====> Post scripts sql on "$trgdbname" are  FAILED!!" RC=$rcode
				echo $now >>${logfilepath}${logfilename}
				syncpoint $trgdbname $step "$LINENO"
				########################################################################
				#   send notification                                                  #
				########################################################################
				send_notification "$trgdbname"_Overlay_abend "Post scripts on "$trgdbname" are  failed" 3
				echo "error.......Exit."
				echo ""
				exit $step
			fi
			echo "END   TASK: $step REFRESH_post_scripts"
		;;
		"1450")
		    ########################################
			#  update log file:                    #
			#        Run DB Autoconfig             #
			########################################
			now=$(date "+%m/%d/%y %H:%M:%S")" ====> Execute $trgdbname Autoconfig Scripts"
			echo $now >>${logfilepath}${logfilename}
			#
			echo "      START TASK: db_adconfig"
			db_adconfig $instname $dbhomepath 
			#
			rcode=$?
			if [ $rcode -ne 0 ] 
			then
				now=$(date "+%m/%d/%y %H:%M:%S")" ====> Autoconfig run for "$trgdbname" is  FAILED!!" RC=$rcode
				echo $now >>${logfilepath}${logfilename}
				syncpoint $trgdbname $step "$LINENO"
				########################################################################
				#   send notification                                                  #
				########################################################################
				send_notification "$trgdbname"_Overlay_abend "Autoconfig run for "$trgdbname" is  failed" 3
				echo "error.......Exit."
				echo ""
				exit $step
			fi
			echo "END   TASK: $step REFRESH_post_scripts"
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
        "1600")
			echo "START   TASK: send_notification"
			########################################################################
			#   send notification that target database overlay has been completed  #
			########################################################################
			send_notification "$trgdbname Overlay completed" "$trgdbname overlay has been completed" 1
			#	
			echo "END     TASK: send_notification"
		;;
        "1650")
			echo "START   TASK: end-of $trgdbname database refresh"
			syncpoint $trgdbname "0 " "$LINENO"
			echo "END     TASK: end-of $trgdbname database refresh"
		;;
                   *)
                        echo "step not found - step: $step around Line ===> " "$LINENO"
                ;;
        esac
done
