os_untar_gz_file()
{
tarfilename=$1
srcfilename=$2
logfile=${3:-untar.log}
tar -xvzf ${tarfilename} -C ${srcfilename} >> ${logfilepath}${logfile}
}