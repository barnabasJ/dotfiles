#! /bin/bash

for dataset in $(zfs list -H | grep -v 'docker' |  cut -f1) 
do
	echo $dataset
	zfs snapshot $dataset@202501062215
done
