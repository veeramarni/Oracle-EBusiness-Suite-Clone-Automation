os_untar_gz_file()
{
tm=$(date "+%m%d%y%H%M%S")
unset ct
ct=$#
if [ $ct -lt 2 ]
then
        echo "Please provide correct arguments"
	usage $0 :UNTAR Requires  "[tarfilename] [srouce filename] ..(optional).. [logfile name] "
        return
else
	unset tarfilename
	tarfilename=$1
	unset srcfilename
	srcfilename=$2
	unset logfile
	logfile=${3:-untar"$tm".log}
	tar -xvzf ${tarfilename} -C ${srcfilename} > ${logfilepath}${logfile}
fi
}