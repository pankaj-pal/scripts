#!/bin/bash
/usr/openv/netbackup/bin/admincmd/bpdbjobs -summary -l > /apps/IPsoft/NetBackup_scripts/dump/bpdbjobs_summary.txt
EST_DATE=`date`
mailx -s "NetBackup Jobs Status on ADCNBUMSTRP1 -- $EST_DATE" Kumar.Chaurasia@ipsoft.com,eric.norman@ihg.com,mohammad.shafi@ihg.com < /apps/IPsoft/NetBackup_scripts/dump/bpdbjobs_summary.txt
[root@adcnbumstrp1 ipsoft]# cat /apps/IPsoft/NetBackup_scripts/daily_failed_full_backups
#  Get failed backups that have occured in the last 24 hours
/usr/openv/netbackup/bin/admincmd/bperror -U -backstat -hoursago 24 |grep Full|grep -v _DB|awk '$1 > "1"' > /tmp/full_fail
#  Get failed database backups that have occured in the last 24 hours
/usr/openv/netbackup/bin/admincmd/bperror -U -backstat -hoursago 24 |grep Full|grep _DB|awk '$1 > "0"' > /tmp/full_db_fail
echo "#############################################################################" > /tmp/mail_full_fail
echo "Failed Full backups in the last 24 hours" >> /tmp/mail_full_fail
echo "STATUS CLIENT        POLICY           SCHED      SERVER      TIME COMPLETED" >> /tmp/mail_full_fail
cat /tmp/full_fail|awk '{print $2}'|sort -u|while read client
do
count=`grep -c $client /tmp/full_fail`
if [ $count -eq 4 ]
then
grep $client /tmp/full_fail|sort -k 2,2 -u |tee -a /usr/local/daily_full_failed_backups >> /tmp/mail_full_fail
fi
done
echo "#############################################################################" >> /tmp/mail_full_fail
echo "Failed Full Database backups in the last 24 hours" >> /tmp/mail_full_fail
echo "STATUS CLIENT        POLICY           SCHED      SERVER      TIME COMPLETED" >> /tmp/mail_full_fail
cat /tmp/full_db_fail |tee -a /usr/local/daily_full_failed_backups >> /tmp/mail_full_fail
echo "#############################################################################" >> /tmp/mail_full_fail
cat /tmp/mail_full_fail|mailx -s "!!! Daily Full Backup Failure Report For Server adcnbumstrp1 !!!" nbapps IHG-backups@ihg.ipcenter.com,mohammad.shafi@ihg.com
######### Save a weeks worth of failed daily full backups ########################
#grep $client /tmp/full_fail|sort -k 2,2 -u >> /usr/local/daily_full_failed_backups
#cat /tmp/full_db_fail >> /usr/local/daily_full_failed_backups
