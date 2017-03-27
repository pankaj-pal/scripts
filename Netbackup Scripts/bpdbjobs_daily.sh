#!/bin/bash
DATE=`date +'%m%d%y'`
/usr/openv/netbackup/bin/admincmd/bpdbjobs > /apps/IPsoft/NetBackup_scripts/bpdbjobs_daily_log/output.bpdbjobs.$DATE
