#!/bin/bash
ps -eaf | grep -v grep | grep clean_orphan.sh
count=`ps -eaf | grep -v grep | grep -c vmware-orphan-cleanup.sh`
echo $count
if [ $count -gt 5 ];
then
                SUBJECT="VM Orphan Cleanup Is Having Problems!"
                EMAIL="admin@foobar.com"
#                EMAIL="tier2@hatsize.com"
                FROM="scripts@foobar.com"
                EMAILMESSAGE="/tmp/emailmessage.txt"
                /bin/echo "vmware-orphan-cleanup.sh is having problems on scripts please check it out" > $EMAILMESSAGE
                /bin/echo "" >> $EMAILMESSAGE
                /bin/echo "" >> $EMAILMESSAGE
                /bin/mailx -s "$SUBJECT" -r "$FROM" "$EMAIL" < $EMAILMESSAGE
                /bin/rm -f /tmp/emailmessage.txt
else
export  PERL_LWP_SSL_VERIFY_HOSTNAME=0
mv -f /scripts/vi-admin/orphan.log /scripts/vi-admin/orphan.log.previous

perl /scripts/vi-admin/removeOrphansFromvCenter.pl --server vcenter.example.com --username vi-admin@vsphere.local --password foobar >> /scripts/vi-admin/orphan.log
