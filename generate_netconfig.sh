#!/bin/bash

if [ "$#" -le '1' ]; then
  echo "Not enough parameters passed to script."
  echo "expected usage ./generate_netconfig.sh 192.168.1.100 myhostname"
  exit 1
fi

replaceIP="$1"
ourHostname="$2"
outputNetfile="cloudinit_data/""$ourHostname""_network_config"

if  [ ! -f "$outputNetfile" ]
  then sed s/\$\{ip_address\}/$replaceIP/g cloudinit_data/template_network_config > $outputNetfile
  echo "output in $outputNetfile"
fi
