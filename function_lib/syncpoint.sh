syncpoint()
{
dbname=$1
stepname=$2
linenum=$3
#
echo "$stepname" "$linenum" >"$abendfile"
}
