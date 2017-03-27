#!/bin/bash
#
# This is a script to page the USS QB Pager in case of NetBackup Failures
# Written by Cisco Vila
#
#

/usr/openv/netbackup/bin/admincmd/bperror -U -backstat -hoursago 24 | awk '{print $1,$2,$3,$6,$7}' | grep -v "(" | grep -v STATUS > /apps/IPsoft/NetBackup_scripts/dump/daily_error_report.txt

ERRPT=/apps/IPsoft/NetBackup_scripts/error_codes.txt



BERT2='mailx -s NetBackup_24_Hour_Error_Report  IHG-backups@ihg.ipcenter.com,mohammad.shafi@ihg.com'

DAILY_REPORT=/apps/IPsoft/NetBackup_scripts/dump/daily_error_report.txt
STATUS=/apps/IPsoft/NetBackup_scripts/dump/status_update.txt


> $STATUS

for i in `awk '{print $1}' $DAILY_REPORT | grep -v 150`
do
                if [ $i -gt 1 ] ; then
                        echo "Status Code $i for job; Error is `grep -w $i $ERRPT | grep -v 150`" >> $STATUS
                fi
done

if [ -f $STATUS -a -s $STATUS ] ; then
        cat $STATUS | $BERT1
        cat $DAILY_REPORT | grep -v -w 150 | grep -v -w 0 | grep -v -w 1 | $BERT2
fi

