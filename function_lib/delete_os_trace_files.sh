delete_os_trace_files()
{
orasid=$1
orahome=$2
MAX_FILE_AGE=$3
DEL_DIR=$4
export ORACLE_SID=${orasid}
export ORACLE_HOME=${orahome}
export PATH=$ORACLE_HOME/bin:$PATH
/usr/bin/find $DEL_DIR -type f -mtime +$MAX_FILE_AGE -print0 | /usr/bin/xargs -r -0 /bin/rm -f
}		

