#!/bin/bash
#
#
. function_lib/encrypt_passwordfile.sh
ls *pwd |while read file
do
  encrypt_passwordfile $file
done