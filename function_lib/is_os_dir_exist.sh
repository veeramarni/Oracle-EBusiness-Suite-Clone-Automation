is_os_dir_exist()
{
unset _bdir
_bdir=$1
if [  -d "${_bdir}" ]
 then
    echo ${_bdir} exist
    return 0
 else
    return 1
fi
}