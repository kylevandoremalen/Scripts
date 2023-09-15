#!/bin/bash

POOL="/data/foobar"

if mountpoint -q ${POOL}

        then

        /bin/echo `date` > /var/log/zfs_backup.log
        /bin/echo "" >> /var/log/zfs_backup.log
        /bin/echo "zfs file system is mounted, commencing backup" >> /var/log/zfs_backup.log
        /bin/echo "" >> /var/log/zfs_backup.log

        /sbin/zrep -S all >> /var/log/zfs_backup.log

        /bin/echo "" >> /var/log/zfs_backup.log
        /bin/echo "backup finished @ `date`" >> /var/log/zfs_backup.log

        else

        exit 0
fi

exit 0
