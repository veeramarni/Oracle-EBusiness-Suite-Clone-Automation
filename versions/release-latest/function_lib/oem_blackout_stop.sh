oem_blackout_stop(){
unset _path
_path=$1
unset _bkname
_bkname=$2
${_path}/emctl stop blackout ${_bkname}
}