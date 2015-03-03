apps_fnd_clean()
{
orasid=$1
orahome=$2
export ORACLE_SID=${orasid}
export ORACLE_HOME=${orahome}
"$ORACLE_HOME"/bin/sqlplus /" as sysdba"  \
			@${sqlbasepath}apps_fnd_clean.sql \
			> ${logfilepath}${orasid}_apps_fnd_clean.log
}