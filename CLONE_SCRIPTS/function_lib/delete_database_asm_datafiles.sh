delete_database_asm_datafiles()
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
		asmcmd rm +DATAC1/${dbname}/DATAFILE/* \
		>${logfilepath}${dbname}_delete_database_asm_datafiles.log
		;;
	*)
		echo "cannot delete data files from +ASM";;
esac
}		

