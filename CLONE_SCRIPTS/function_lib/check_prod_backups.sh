#!/bin/bash
#
check_prod_backups()
{
#
if [ $# -lt 1 ]
then
        echo "Please provide database name"
	usage $0 :check_prod_backups Requirs  "[DTABASE NAME]"
        return 99
fi
#
srcdbname=$1
#
case $srcdbname in
	"DPGN")
		if [ -d /migration/refresh/DPGN ] 
		then
			srcdbname=$1
  			echo "exists."
		fi
		;;
	"DPTP")
		if [ -d /migration/refresh/DPTP ] 
		then
			srcdbname=$1
  			echo "exists."
		fi
		;;
	"DBM01")
		if [ -d /migration/refresh/DBM01 ] 
		then
			srcdbname=$1
  			echo "exists."
		fi
		;;
	*)
  		echo "Error: /migration/refresh/"$srcdbname" not found"
  		return 99
		;;
esac
echo "RC: " $?
}

