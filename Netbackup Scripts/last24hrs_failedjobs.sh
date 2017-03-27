#!/bin/bash
rm -rf /apps/IPsoft/NetBackup_scripts/dump/backup_sum_file.txt 
rm -rf /apps/IPsoft/NetBackup_scripts/dump/backup_report_file.csv 

sum=`/usr/openv/netbackup/bin/admincmd/bperror -hoursago 24 | grep "EXIT STATUS" | grep -wv "EXIT STATUS [0|1]" | awk '{print $6}' | sort | uniq | wc -l`
if [ $sum -lt 1 ]
then
        echo "Total Number of jobs that failed with errors : $sum" > /apps/IPsoft/NetBackup_scripts/dump/backup_sum_file.txt
else
        echo "Job_ID,Exit_Status,Job_Start_Time,Job_End_Time,NBU_Master_Server,NBU_Client_Server,NBU_Policy,Schedule_Type,Failure_Description" > /apps/IPsoft/NetBackup_scripts/dump/backup_report_file.csv
        echo "Total Number of jobs that failed with errors : $sum" >> /apps/IPsoft/NetBackup_scripts/dump/backup_sum_file.txt

        for id in `/usr/openv/netbackup/bin/admincmd/bperror -hoursago 24 | grep "EXIT STATUS" | grep -wv "EXIT STATUS [0|1]" | awk '{print $6}' | sort | uniq`
        do
        ##############
        Job_ID="$id"
        ##############
        Exit_Status=`/usr/openv/netbackup/bin/admincmd/bperror -jobid "$id" | grep EXIT | awk '{print $19}' | head -1`
        ##############
        year=`date +%Y`
        Job_Start_Time=`/usr/openv/netbackup/bin/admincmd/bperror -jobid "$id" -U | grep "$year" | awk '{print $1" "$2" ""EST"}' | head -1`
        Job_End_Time=`/usr/openv/netbackup/bin/admincmd/bperror -jobid "$id" -U | grep "$year" | awk '{print $1" "$2" ""EST"}' | tail -1`
        ##############
        NBU_Master_Server=adcnbumstrp1
        ##############
        NBU_Client_Server=`/usr/openv/netbackup/bin/admincmd/bperror -jobid "$id" | grep EXIT | awk '{print $12}' | head -1`
        ##############
        NBU_Policy=`/usr/openv/netbackup/bin/admincmd/bperror -jobid "$id" | grep EXIT | awk '{print $14}' | head -1`
        ##############
        Schedule_Type=`/usr/openv/netbackup/bin/admincmd/bperror -jobid "$id" | grep EXIT | awk '{print $16}' | head -1`
        ##############
        Failure_Description=`/usr/openv/netbackup/bin/admincmd/bperror -S "$Exit_Status" | awk 'NR==1' | sed -e 's/ /_/g'`
        ##############
        echo "$Job_ID,$Exit_Status,$Job_Start_Time,$Job_End_Time,$NBU_Master_Server,$NBU_Client_Server,$NBU_Policy,$Schedule_Type,$Failure_Description" >> /apps/IPsoft/NetBackup_scripts/dump/backup_report_file.csv
        done
fi
#echo "\n\n\n" >>  /apps/IPsoft/NetBackup_scripts/dump/backup_sum_file.txt
echo "Summary of all jobs:" >> /apps/IPsoft/NetBackup_scripts/dump/backup_sum_file.txt
/usr/openv/netbackup/bin/admincmd/bperror -backstat -U -by_statcode >>  //apps/IPsoft/NetBackup_scripts/dump/backup_sum_file.txt

EST_DATE=`date`


mailx -a /apps/IPsoft/NetBackup_scripts/dump/backup_report_file.csv  -s "NetBackup Summary Report of NBU server ADCNBUMSTRP1 -- $EST_DATE" kumar.chaurasia@ipsoft.com,adminindia@ipsoft.com,mohammad.shafi@ihg.com < /apps/IPsoft/NetBackup_scripts/dump/backup_sum_file.txt
