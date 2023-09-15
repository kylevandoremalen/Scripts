#!/bin/bash

BU_LOG=/var/log/backup_puppet.log

BU_DATE=`date +%Y-%m-%d`

/usr/bin/echo "${BU_DATE} Preparing puppet-foreman backup for nightly rsync to /some/backup/path/ on backup server" > ${BU_LOG}

/usr/bin/echo "" >> ${BU_LOG}

cd /

# Backup Puppet and Foreman files
/usr/bin/tar -czf puppet-foreman_bu.tar.gz etc/httpd/conf etc/httpd/conf.d opt/puppetlabs usr/share/puppet etc/pki/katello/puppet etc/sysconfig/puppet opt/theforeman usr/share/foreman-installer usr/share/foreman var/lib/foreman etc/foreman 2>> ${BU_LOG}

/usr/bin/mv /puppet-foreman_bu.tar.gz /backup/${BU_DATE}_puppet-foreman_bu.tar.gz 2>> ${BU_LOG}

/usr/bin/find /backup/ -maxdepth 1 -type f -mtime +7 -exec rm -rf {} \; 2>> ${BU_LOG}

/usr/bin/echo "" >> ${BU_LOG}
/usr/bin/echo done.. >> ${BU_LOG}
