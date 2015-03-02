syncpoint()
{
dbname=$1
stepname=$2
linenum=$3
ldbname=`echo "$dbname" | tr [A-Z] [a-z]`
#
case $dbname in
        "DSGN")
                echo "$stepname" "$linenum" >"$abendfile"
                ;;
        "DSTP")
                echo "$stepname" "$linenum" >"$abendfile"
                ;;
        "DBM01")
                echo "$stepname" "$linenum"  >"$abendfile"
                ;;
        *)
                echo "wrong Database for RESTART file";;
esac
}
