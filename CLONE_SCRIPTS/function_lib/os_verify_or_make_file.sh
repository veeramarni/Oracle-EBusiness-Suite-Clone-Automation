os_verify_or_make_file()
{
unset bfile
bfile=$1
unset dataecho
dataecho=$2
# Verify backup directory $bfile exists, otherwise create it.
if [[ ! -f "$bfile" ]]; then
  touch "$bfile"
  echo ${dataecho} > "$bfile"
  if [[ ! -f "$bfile" ]]; then
        echo "Error, cannot create $bfile";
        exit 1
  fi
fi
}