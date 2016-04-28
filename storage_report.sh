#!/bin/bash
echo "******************************************************************************************************************"
echo "*************************Capacity Report for Storage of `date` *****************************"
echo "******************************************************************************************************************"
echo
echo

echo "=========================================="
echo "Capacity Summary for PROD VNX"
echo "=========================================="

storagePoolAvail=`naviseccli  -h 192.168.104.22 storagepool -list  -availableCap   | grep GB  | awk '{sum+=$NF}END{print sum}'`
raidGroupAvail=`naviseccli  -h 192.168.104.22 getrg -lusc | grep Free  | awk '{sum = $NF/(2*1024*1024)} END {print sum}'`

freeStoragePool=`echo $storagePoolAvail + $raidGroupAvail | bc`
freeRawDisk=`naviseccli  -h 192.168.104.22 getdisk  |  grep  -A6 "State:                   Unbound" | grep Capacity  | tail -n+5  | awk '{sum+=$NF}END{print sum/1024}'`
used=`echo 359472.77 - $freeStoragePool - $freeRawDisk | bc`

echo "Free Storage Pool: "$freeStoragePool" GB"
echo "Free Raw Disk: "$freeRawDisk" GB"
echo "User: "$used" GB"


echo
echo


echo "=========================================="
echo "Capacity Summary for PROD DD"
echo "=========================================="
ssh  192.168.104.31 -l msap.manage  filesys show space
echo
echo


echo "****************************************END *******************************************"
