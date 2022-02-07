appschangepassword()
{
unset _appspass
_appspass=$1
unset _dbsystem
_dbsystem=$2
unset _appssysadmin
_appssysadmin=$3
unset _newappspass
_newappspass=$4
# App password will be set at the last. 
FNDCPASS apps/${_appspass} 0 Y system/${_dbsystem} USER   SYSADMIN  ${_appssysadmin} > ${logfilepath}changesysadminpass.log 2>&1
FNDCPASS apps/${_appspass} 0 Y system/${_dbsystem} SYSTEM APPLSYS ${_newappspass} > ${logfilepath}changeappspass.log 2>&1
}