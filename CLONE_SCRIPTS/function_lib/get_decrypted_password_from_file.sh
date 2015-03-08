get_decrypted_password_from_file()
{
unset _passfile
_passfile=$1
unset _user
_user=$2
cat ${_passfile} |grep -wF ${_user} | awk -F"=" '{print $2"="$3}' | while read arg 
do
lpp=`echo $arg | openssl aes-256-cbc -d -a -salt -k aes-256-cbc`
done
echo $lpp
}