os_tar_gz_file()
{
now=$(date "+%m/%d/%y %H:%M:%S")
unset ct
ct=$#
if [ $ct -lt 3 ]
then
        echo "Please provide correct arguments"
	usage $0 :TAR Requires  "[tarfilename] [srouce filename] [from directory] ..(optional).. [logfile name] "
        return
else
    unset tarfilename
	tarfilename=$1
	unset srcfilename
	srcfilename=$2
	unset frmdir
	frmdir=$3
	unset logfile
	logfile=${4:-tar"$now".log}
	cd $frmdir
	tar -cvzf ${tarfilename} ${srcfilename} >> ${logfilepath}${logfile}
fi
}