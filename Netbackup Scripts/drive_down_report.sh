#!/bin/bash

/usr/openv/volmgr/bin/vmoprcmd | grep DOWN-TLD > /apps/IPsoft/NetBackup_scripts/dump/down_drives.txt
EST_DATE=`date`
mailx -s "Drives DOWN report on adcnbumstrp1 -- $EST_DATE" kchauras@ipsoft.com,adminindia@ip-soft.net < /apps/IPsoft/NetBackup_scripts/dump/down_drives.txt
