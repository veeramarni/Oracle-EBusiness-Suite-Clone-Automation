os_delete_move_file()
{
unset ct
ct=$#
if [ $ct -lt 2 ]
then
        echo "Please provide correct arguments"
	usage $0 :Delte or Move Requires  "[D or M] [Full File Path] [NEW PATH (if file needs to be moved)] "
        return
else
    unset type
	type=$1
    unset filepath
	filepath=$2
	unset
	newpath=$3
	if [ $ct == 2 && $type == 'D' ]
	then
	rm $filepath
	elif [ $ct == 3 && $type == 'M' ]
	then
	mv $filepath $newpath
	else 
	echo "In valid number of arguments"
	fi
fi
}