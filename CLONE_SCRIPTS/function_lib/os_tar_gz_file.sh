os_tar_gz_file()
{
now=$(date "+%m/%d/%y %H:%M:%S")
unset ct
ct=$#
if [ $ct -lt 2 ]
then
        echo "Please provide correct arguments"
	usage $0 :TAR Requires  "[tarfilename] [srouce filename] ..(optional).. [logfile name] "
        return
else
    unset tarfilename
	tarfilename=$1
	unset srcfilename
	srcfilename=$2
	unset logfile
	logfile=${3:-tar"$now".log}
	tar -cvzf ${tarfilename} ${srcfilename} >> ${logfilepath}${logfile}
fi
}