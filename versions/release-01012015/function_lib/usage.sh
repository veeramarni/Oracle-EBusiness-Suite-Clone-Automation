usage()
{
	script=$1
	shift
	
	echo ""
	echo "Usage: `basename $script` $*" 1>&2 
	echo ""
	echo ""
	return 2

}
