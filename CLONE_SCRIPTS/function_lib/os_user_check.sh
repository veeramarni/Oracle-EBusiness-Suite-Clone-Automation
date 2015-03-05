os_user_check()
{
user=$1
if [ `/usr/bin/whoami` != $user ]; then
  /bin/echo 'Error: User must be $user'
  exit 1
fi
}
