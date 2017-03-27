#!/bin/bash
# Test for Teradata BAR sever backups in 24 hours.
path=/usr/openv/netbackup/bin/admincmd
testvalue=8
count=`$path/bperror -U -backstat -hoursago 24 |egrep "TD_adctdbarp1-1|TD_adctdbarp1-2|TD_adctdbarp1-3|TD_adctdbarp1-4|TD_adctdbarp1-5|TD_adctdbarp1-6"|grep "^  0"|sort -k 3,3|sort -um -k 3,3|wc -l`
if [ $count -lt $testvalue ]
then
echo "There have been no successful Backups on BAR server in the past 24 hours. We will send a report for failures" |/bin/mailx -s "!! Teradata Backup Failure Message !!" kumar.chaurasia@ipsoft.com
fi
# Test for failed Teradata backup
rm /apps/IPsoft/NetBackup_scripts/dump/taradata_failures > /dev/null 2>&1
$path/bperror -U -backstat -hoursago 24 |egrep "TD_adctdbarp1-1|TD_adctdbarp1-2|TD_adctdbarp1-3|TD_adctdbarp1-4|TD_adctdbarp1-5|TD_adctdbarp1-6"|grep -v "^  0"|sort -k 3,3 > /apps/IPsoft/NetBackup_scripts/dump/taradata_failures

if [ -s /apps/IPsoft/NetBackup_scripts/dump/taradata_failures ]
then
cat /apps/IPsoft/NetBackup_scripts/dump/taradata_failures | mailx -s "!! Teradata Backup Failure Report !!" kumar.chaurasia@ipsoft.com
fi

