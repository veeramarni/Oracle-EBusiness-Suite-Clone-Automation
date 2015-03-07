is_os_file_exist()
{
unset bfile
bfile=$1
if [  -f "$bfile" ]
 then
    echo $bfile exist
    return 0
 else
    return 1
fi
}