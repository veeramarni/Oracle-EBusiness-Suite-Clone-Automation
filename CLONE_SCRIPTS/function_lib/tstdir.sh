#!usr/bin/sh
. /u01/app/oracle/scripts/refresh/go_live_refresh/functions_lib/check_prod_backups.sh
. /u01/app/oracle/scripts/refresh/go_live_refresh/functions_lib/dir_empty.sh
#heck_prod_backups PTP
dir_empty /migration/refresh/DPGN
dir_empty /migration/refresh/DPTP
