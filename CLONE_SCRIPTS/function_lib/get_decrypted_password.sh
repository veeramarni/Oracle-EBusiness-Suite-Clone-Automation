get_decrypted_password()
{
unset _pas
_pas=$1
lpp=`echo ${_pas} | openssl aes-256-cbc -d -a -salt -k aes-256-cbc`
return $lpp
}