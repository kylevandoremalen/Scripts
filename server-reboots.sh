#!/bin/bash

serverlist=$1
servers=`cat $serverlist`

# Loop through server names in servers.txt
for server in $servers; do
  echo "Rebooting $server" 
  ssh root@$server "nohup reboot &>/dev/null & exit"
  echo "Waiting..."
  sleep 45
  echo "-------------------------"
done

echo "All servers have been rebooted! heck ya"
exit 0
