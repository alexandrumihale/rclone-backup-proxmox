#!/bin/bash

original_backups="/pooldirectory/dump" # Set this to where your vzdump files are stored
achive_place="/backups"
maxdays=7
rclone_instance="gdrive:" # do not forget the : 
date_now=$(date +'%d-%h-%Y')

# find $original_backups -type f -mtime +$max_days -exec /bin/rm -f {} \;
search=$(find -L $archive_place -type f -name '*.tar' | grep *.tar )



#tar cvfP /backups/backup${date_now}.tar /pooldirectory/dump/* .
#rclone copy $archive_place/*.tar $rclone_instance



## idea: delete if different date NO DRY RUN
#rclone --dry-run --include "*.tar" delete $rclone_instance

