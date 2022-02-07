os_verify_or_make_directory()
{
bdir=$1
# Verify backup directory $bdir exists, otherwise create it.
if [[ ! -d "$bdir" ]]; then
  mkdir -p "$bdir"
  if [[ ! -d "$bdir" ]]; then
        echo "Error, cannot create $bdir";
        exit 1
  fi
fi
}