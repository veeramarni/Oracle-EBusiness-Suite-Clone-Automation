encrypt_passwordfile()
{
unset _passfile
_passfile=$1
tm=$(date "+%m%d%y%H%M%S")
_tempfile=tempfile$tm
>${_tempfile}
cat ${_passfile} | awk -F"=" '{print $1,$2}' | while read arg arg2
do 
echo "Read first user as $arg2"
lnt=`echo ${#arg2}` 
echo $lnt
if [ $lnt -lt 15 ]
then 
echo "Encrypting password for $arg"
# remove double quotes at prifix and suffix if exist
arg2=`echo $arg2 | sed -e 's/^"//' -e 's/"$//'`
arg2=`echo $arg2 | openssl enc -e -aes-256-cbc -a -salt -k aes-256-cbc`
echo "encrypted pass is $arg2"
echo $arg=\"$arg2\" >> ${_tempfile}
else
echo $arg=$arg2"=\"" >> ${_tempfile}
fi 
done
mv ${_tempfile}  ${_passfile}
}
