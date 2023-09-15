#!/bin/bash
#
# This script generates a report of applicable package updates from Foreman content hosts.
# The first input specifies the lifecycle environment we want the report for
# The second input is the email to send the report to once it's generated
# Kyle Vandoremalen - 10/11/2022

# User-prompted inputs

enviro=$1
email=$2

echo "Generating ${enviro} patching report. This can take up to ~5 minutes."

# Set reporting variables

LIFECYCLE=${enviro^^}
TSTAMP=$(date "+%m-%d-%Y")
HOSTS=$(hammer --csv host list --search "lifecycle_environment = $LIFECYCLE"| grep -vi '^ID' | awk -F, {'print $2'});

# These touch lines are needed to send temp files to the real /tmp directory

touch /tmp/packages-temp.txt
touch /tmp/$LIFECYCLE-patching-$TSTAMP-temp.txt

# Generate a list of applicable package updates for each host in the lifecycle environment

for HOST in $HOSTS; do
echo $HOST > /tmp/packages-temp.txt
hammer --csv package list --host $HOST --packages-restrict-applicable true | grep -vi '^ID' | awk -F, {'print $2'} >> /tmp/packages-temp.txt

# Next, we'll take our report outputs, convert to .csv, and transpose them to make them presentable

tr "\n" "\," < /tmp/packages-temp.txt > /tmp/packages-rows-temp.txt
cat /tmp/packages-rows-temp.txt >> /tmp/$LIFECYCLE-patching-$TSTAMP-temp.txt
echo "" >> /tmp/$LIFECYCLE-patching-$TSTAMP-temp.txt
done

# (This nasty snippet is transposing all rows into columns instead)

awk -F, '{for(i=1;i<=NF;i++){A[NR,i]=$i}}
END{for(i=1;i<=NF;i++){
    gsub(/,+/, ",", s) # Remove extra commas
    for(j=1;j<=NR;j++){
        s=(s==""?A[j,i]:s","A[j,i])
    }
    print s;s=""
}}' /tmp/$LIFECYCLE-patching-$TSTAMP-temp.txt > /tmp/$LIFECYCLE-patching-$TSTAMP.txt

sed 's/ \+/,/g' /tmp/$LIFECYCLE-patching-$TSTAMP.txt > /scripts/reports/$LIFECYCLE-patching-$TSTAMP.csv


# Mail the generated .csv file to an email address

/bin/mailx -a /scripts/reports/$LIFECYCLE-patching-$TSTAMP.csv -s "Patching report" $email < /dev/null > /dev/null 2>&1
