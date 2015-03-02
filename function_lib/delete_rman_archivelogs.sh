delete_rman_archivelogs()
{
orasid=$1
orahome=$2
export NLS_DATE_FORMAT='DD-MM-RRRR HH24:MI:SS'
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_SID=${orasid}
export ORACLE_HOME=${orahome}

#
case $orasid in
	$orasid)
		rman target / @${rmanbasepath}delete_rman_archivelogs.rcv \
		> ${logfilepath}${logfilename}_delete_rman_archivelogs.log
		;;
	*)
		echo "wrong target database for RMAN delete archivelogs";;
esac
}		

