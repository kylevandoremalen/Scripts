#!/bin/bash
# Script to confirm kernel versions running

# Server list variable input
serverlist=$1
servers=`cat $serverlist`
result='result.txt'

echo -e "Servername \t\t kernel version"> $result

#Loop through each server in list and detect kernel
for server in $servers
do
kernel=`ssh root@${server} "uname -r"`
echo -e "$server \t\t $kernel" >> $result
done

cat $result
