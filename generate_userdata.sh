#!/bin/bash

if [ "$#" -lt '1' ]; then
  echo "Not enough parameters passed to script."
  echo "expected usage ./generate_userdata.sh myhost"
  exit 1
fi

ourHostname="$1"
outputUserfile="cloudinit_data/""$ourHostname""_user_data"
if  [ ! -f "$outputNetfile" ]
  then sed s/\$\{hostname\}/$ourHostname/g cloudinit_data/template_user_data > $outputUserfile
  echo "output in $outputUserfile"
fi

echo "output in $outputUserfile"
