delete_sourcedb_backups()
{
srcdbname=$1
#
if [ $# -lt 1 ] 
then
	echo ""
	echo ""
        echo " ====> Abort!!!. Invalid database name for backups"
        usage $0 :delete_sourcedb_backups.sh  "[DATABASE NAME]"
	echo ""
	echo ""
        exit 5
fi
#
find /migration/refresh/$srcdbname/* -exec rm -f {} \;
} 
