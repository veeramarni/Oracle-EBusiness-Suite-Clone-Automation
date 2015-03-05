os_tar_gz_backup()
{
tarfilename=$1
srcfilename=$2
logfile=$3||anonymous_tar.log
tar -cvzf $1 $2 & > ${logfilepath}${logfile}
}