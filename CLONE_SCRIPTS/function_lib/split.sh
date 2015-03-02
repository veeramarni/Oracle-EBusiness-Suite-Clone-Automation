split()
{
step=$1
awk '/'"$step"'/,/##end##/' "$basepath"2000_overlay_staging2.sh >restart_overlay_staging
cat "$basepath"restart_inst "$basepath"restart_overlay_staging >"$basebath"restart_2000_overlay_staging2.sh
}
