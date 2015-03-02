delete_database_asm_tempfile()
{
dbname=$1
ldbname=`echo "$dbname" | tr [A-Z] [a-z]`
#
orasid="$dbname"1
export ORACLE_SID=+ASM1
export ORACLE_HOME=/u01/app/12.1.0.1/grid
export NLS_DATE_FORMAT='DD-MM-RRRR HH24:MI:SS'
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_BASE=/u01/app/oracle
#
#
case $dbname in
	"DSGN")
		asmcmd rm +DATAC1/DSGN/TEMPFILE/* \
		>/u01/app/oracle/scripts/refresh/logs/DSGN_delete_database_asm_tempfile.log
		;;
	"DSTP")
		asmcmd rm +DATAC1/DSTP/TEMPFILE/* \
		>/u01/app/oracle/scripts/refresh/logs/DSTP_delete_database_asm_tempfile.log
		;;
	"DBM01")
		asmcmd rm +DATAC1/DBM01/TEMPFILE/* \
		>/u01/app/oracle/scripts/refresh/logs/DBM01_delete_database_asm_tempfile.log
		;;
	*)
		echo "cannot delete TEMPFILE from +ASM";;
esac
}		

