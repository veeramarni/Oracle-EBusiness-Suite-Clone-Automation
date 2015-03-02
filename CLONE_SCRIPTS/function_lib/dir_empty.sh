dir_empty()
{
if [ $# -lt 1 ]
then
	return 9
fi
#
dirpath=$1
#
if [ "$(ls  -A $dirpath)" ] 
then
	return 0
else
	return 9
fi
}
