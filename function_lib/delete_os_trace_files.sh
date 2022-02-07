delete_os_trace_files()
{
MAX_FILE_AGE=$1
DEL_DIR=$2
if [ -z "${DEL_DIR+1}" ]; then
   read -p "Enter the directory from where the files need to be deleted : " DEL_DIR
   /bin/echo
fi
/usr/bin/find $DEL_DIR -type f -mtime +$MAX_FILE_AGE -print0 | /usr/bin/xargs -r -0 /bin/rm -f
}		

