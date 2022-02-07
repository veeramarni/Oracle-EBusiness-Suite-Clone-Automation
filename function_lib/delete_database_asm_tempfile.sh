delete_database_asm_tempfile()
{
orasid=$1
orahome=$2
dbname=$3
#
export ORACLE_SID=${orasid}
export ORACLE_HOME=${orahome}
export PATH=$ORACLE_HOME/bin:$PATH
#
case $dbname in
	$dbname)
		asmcmd rm +DATAC1/${dbname}/TEMPFILE/* \
		>${logfilepath}${dbname}_delete_database_asm_tempfile.log
		;;
	*)
		echo "cannot delete TEMPFILE from +ASM";;
esac
}		

