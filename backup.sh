#!/bin/bash

original_backups="/pooldirectory/dump" # Set this to where your vzdump files are stored
archive_place="/backups"
maxdays=7
rclone_instance="gdrive:" # do not forget the : 
date_now=$(date +'%d-%h-%Y')

# delete file older than maxdays
echo "Deleting files..."
find -L $archive_place -mtime $maxdays -name *.tar -exec rm -f {} \;


echo "Archiving files"
tar cfP $archive_place/backup${date_now}.tar /pooldirectory/dump/* .

echo "Deleting old backup"
## idea: delete if different date NO DRY RUN
rclone --dry-run --include "*.tar" delete $rclone_instance

echo "Cloning..."
rclone --dry-run copy $archive_place/*.tar $rclone_instance
