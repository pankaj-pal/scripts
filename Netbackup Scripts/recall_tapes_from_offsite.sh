#!/bin/bash
EST_DATE=`date`
DATE_AWK=`date | awk '{print $1,$2,$3}'`
echo -e "Below is the tape list which we need to recall from offsite for $DATE_AWK \n" >  /apps/IPsoft/NetBackup_scripts/dump/recall_tape


echo "==================" >> /apps/IPsoft/NetBackup_scripts/dump/recall_tape

/usr/openv/netbackup/bin/goodies/available_media | grep -i  none | grep -i  available | awk '{print $1}' >  /apps/IPsoft/NetBackup_scripts/dump/recall_tape_list

TOTAL_TAPES=`cat /apps/IPsoft/NetBackup_scripts/dump/recall_tape_list | wc -l`

echo -e  " TOTAL NUMBER OF TAPES NEED TO BE RECALLED IS $TOTAL_TAPES \n" >> /apps/IPsoft/NetBackup_scripts/dump/recall_tape

echo "==================" >> /apps/IPsoft/NetBackup_scripts/dump/recall_tape

for i in `cat /apps/IPsoft/NetBackup_scripts/dump/recall_tape_list` ; do echo "tape id $i";  /usr/openv/volmgr/bin/vmquery -m $i | grep -i  barcode;echo "+++++++++++"; done >> /apps/IPsoft/NetBackup_scripts/dump/recall_tape

mailx -s "!!! Recall tapes from Irom Mount -- $EST_DATE !!!" kchauras@ipsoft.com,occ@ihg.com,mohammad.shafi@ihg.com  < /apps/IPsoft/NetBackup_scripts/dump/recall_tape
