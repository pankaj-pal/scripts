#!/bin/bash

# AN essential function

die () {
    echo >&2 "$@"
    exit 1
}

#preliminary work
NAVICLI=/opt/Navisphere/bin/naviseccli
cat /dev/null > /tmp/mirror_name_with_sec_lunid

#Checking the number of variables entered

[ "$#" -eq 1 ] || die "Script accept only 1 argument, $# provided"

#Defining variables
group_name=$1

#checking group name


#We going to do following task in below loop:
#1> Remove the mirror from primary site from the group
#2> Collect the LUNID from the mirror in secondary site
#3> Destroy the mirror in secondary site

$NAVICLI -h 192.168.104.21 mirror -async   -listgroups -name $group_name -mirrors | grep "Mirror Name" | awk '{print $NF}' | while read mirror_name
do
	#Removing the mirror from local only group on secondary array
	echo "Processing $mirror_name"
	$NAVICLI -h 192.168.108.21 mirror -async -removefromgroup -name $group_name -mirrorname  $mirror_name -o -force
	$NAVICLI -h 192.168.104.21 mirror -async -removefromgroup -name $group_name -mirrorname  $mirror_name -o -force
	#Collecting the lunID in secondary array for the mirrors
	lun_id=`$NAVICLI -h 192.168.108.21 mirror -async -list -name $mirror_name -lun | grep "Logical Unit Numbers:" | awk  '{print $NF}'`
	echo -e $mirror_name "\t" $lun_id >> /tmp/mirror_name_with_sec_lunid
	#Destroying the mirror on secondary site now
	$NAVICLI -h 192.168.108.21 mirror -async -destroy -name $mirror_name -o
done

#deleting the CG on secondary site
echo "deleting CG $group_name on secondary side"
$NAVICLI -h 192.168.108.21 mirror -async -destroygroup -name $group_name -o


#Adding the secondary image to the mirrors at primary site and attaching the mirrors in the CG
echo "We are going to add the secondary image to the mirrors at primary site and attaching the mirrors in the CG at primary site"
cat /tmp/mirror_name_with_sec_lunid | while read mirror_name lun_id
do
	echo "Attaching $mirror_name"
	$NAVICLI -h 192.168.104.21 mirror -async -addimage  -name $mirror_name -arrayhost 192.168.108.21 -lun $lun_id
	$NAVICLI -h 192.168.104.21 mirror -async -addtogroup -name $group_name  -mirrorname $mirror_name
done

echo "Work done, Enjoy Madi!"

	
