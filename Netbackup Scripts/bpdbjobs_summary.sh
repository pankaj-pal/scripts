#!/bin/bash
/usr/openv/netbackup/bin/admincmd/bpdbjobs -summary -l > /apps/IPsoft/NetBackup_scripts/dump/bpdbjobs_summary.txt
EST_DATE=`date`
mailx -s "NetBackup Jobs Status on ADCNBUMSTRP1 -- $EST_DATE" Kumar.Chaurasia@ipsoft.com,eric.norman@ihg.com,mohammad.shafi@ihg.com < /apps/IPsoft/NetBackup_scripts/dump/bpdbjobs_summary.txt
