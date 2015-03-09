get_decrypted_password_from_file()
{
unset _passfile
_passfile=$1
unset _user
_user=$2
unset lpp
cat ${_passfile} |grep -wF ${_user} | while IFS="=" read arg arg2
do
# remove double quotes at prifix and suffix if exist
arg2=`echo $arg2 | sed -e 's/^"//' -e 's/"$//'`
lpp=`echo $arg2 | openssl aes-256-cbc -d -a -salt -k aes-256-cbc`
done
echo $lpp
}