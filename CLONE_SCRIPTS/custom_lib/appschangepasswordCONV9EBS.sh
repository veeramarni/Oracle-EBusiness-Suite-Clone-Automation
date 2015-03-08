appschangepassword()
{
# App password will be set at the last. 
FNDCPASS apps/$1 0 Y system/manager USER   SYSADMIN  sysadmin
FNDCPASS apps/$1 0 Y system/manager SYSTEM APPLSYS $2
}