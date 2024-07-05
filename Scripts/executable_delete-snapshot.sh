#! /bin/bash

for snapshot in $(zfs list -t snapshot -H | grep 2023 |  cut -f1) 
do
	echo $snapshot
	zfs destroy -R $snapshot
done
