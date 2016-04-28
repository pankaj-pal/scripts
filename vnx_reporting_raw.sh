#!/bin/bash

number_of_pools=`naviseccli  -h 192.168.104.22 storagepool -list | grep "Pool ID"  | wc -l`

cat /dev/null > machine_name.csv

echo 'Pool Name','Total GB ','Used GB ','Available GB ','Percent Full ' >> machine_name.csv
for (( i=0; i<$number_of_pools; i++ )); 
do 
naviseccli  -h 192.168.104.22 storagepool -list  -id $i -availableCap -consumedCap -UserCap  -prcntFull  | egrep 'Name|GB|Full' > pool_$i 
echo `grep Name pool_$i |awk '{print $3}'`","`grep -i User pool_$i |awk '{print $4}'`","`grep -i Consumed pool_$i |awk '{print $4}'`","`grep -i Available pool_$i |awk '{print $4}'`","`grep -i Full pool_$i |awk '{print $3}'` >> machine_name.csv
done


 Total=`grep -v Total machine_name.csv |  awk -F  ',' '{ {Total+=$2;  Used+=$4; Avail+=$5} } END {print "Sum of All Pool,"Total,","Used,","Avail}'`

 echo $Total >> machine_name.csv
