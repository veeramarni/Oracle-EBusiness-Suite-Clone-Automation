os_tar_gz_file()
{
tarfilename=$1
srcfilename=$2
logfile=${3:-tar.log}
tar -cvzf ${tarfilename} ${srcfilename} >> ${logfilepath}${logfile}
}