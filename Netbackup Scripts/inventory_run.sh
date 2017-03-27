#!/bin/bash
/usr/openv/volmgr/bin/vmupdate  -rn 0 -rt TLD -empty_map > /apps/IPsoft/NetBackup_scripts/dump/inventory_run
EST_DATE=`date`
mailx -s "Inventory Status on adcnbumstrp1 -- $EST_DATE" kchauras@ipsoft.com,mohammad.shafi@ihg.com  < /apps/IPsoft/NetBackup_scripts/dump/inventory_run
