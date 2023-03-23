#!/bin/bash

original_backups="/pooldirectory/dump" # Set this to where your vzdump files are stored
archive_place="/backups"
maxdays=7
rclone_instance="gdrive:" # do not forget the : 
date_now=$(date +'%d-%h-%Y')


i=1
sp="/-\|"

# delete file older than maxdays
echo "Deleting files..."
find -L $archive_place -mtime $maxdays -name *.tar -exec rm -f {} \;


echo "Archiving files"
cd $archive_place
tar zcfP backup${date_now}.tar $original_backups/*
echo "Archived!"


echo "Deleting old backup"
rclone --include "*.tar" delete $rclone_instance
echo "Deleted!"

echo "Cloning..."
rclone copy $archive_place/*.tar $rclone_instance
echo "Cloning done!"


