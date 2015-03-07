is_os_file_exist()
{
unset bfile
bfile=$1
if [[  -f "$bfile" ]]; then
 then
    return 0
 else
    return 1
fi
}