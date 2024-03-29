custom_sql_run()
{
unset ct
ct=$#
if [ $ct -lt 4 ]
then
	## the calling script should set the following variables prior to calling this function:
	## _sqlfile should be set to the .sql file to be executed in SQL Plus (fully qualified path).
	## Takes upto 3 sql params
        echo "Please provide atleast 4 arguments as shown below"
	usage $0 :SQL Execution Requires  "[ORASID] [ORAPID] [ORAHOME] [TNSHOME] [DBSTRING] [USERNAME] [PASSWORD] [SQLFILE] ...(optional)..[SQL PARAM1] [SQL PARAM2] [SQL PARAM3]"
		echo "If DBSTRING or ORASID are not known then set as empty string but make sure one of them is set"
        return
else
	unset _orasid
	_orasid=$1
	unset _orapdb
	_orapdb=$2
	unset _orahome
	_orahome=$3
	unset _tnshome
	_tnshome=$4
	unset _dbstring
	_dbstring=$5
	unset _user
	_user=$6
	unset _pass
	_pass=$7
	unset _sqlfile
	_sqlfile=$8
	unset _sqlparm1
	_sqlparm1=$9
	unset _sqlparm2
	_sqlparm2=$10
	unset _sqlparm3
	_sqlparm3=$11
	unset _spoolfile
	_spoolfile=${logfilepath}${_orasid}sqlspool"$tm".log
	tm=$(date "+%m%d%y%H%M%S")
	unset _lgfile
	_lgfile=${logfilepath}${_orasid}sqlexecution"$tm".log
	export ORACLE_SID=${_orasid}
	export ORACLE_PDB_SID=${_orapdb}
	export ORACLE_HOME=${_orahome}
	unset _at
	if [[ -z "${_dbstring// }" ]]
	then
		if [[ -z "${_orasid// }" ]]
		then	
			echo "Need to define ORASID or DBSTRING, but both cannot be empty"
		else
			_at=""
		fi
	else
		_at="@"
	fi
	if [[ -z "${_tnshome// }" ]]
	then
		echo "TNS is not set"
	else
		export TNS_ADMIN=${_tnshome}
	fi

# Avoid using TAB when using EOF
${ORACLE_HOME}/bin/sqlplus -s /nolog > ${_lgfile} <<EOFsql
WHENEVER SQLERROR EXIT FAILURE;
connect ${_user}/${_pass}${_at}${_dbstring}
START ${_sqlfile} ${_spoolfile} ${_sqlparm1} ${_sqlparm2} ${_sqlparm3}
EOFsql
fi
}