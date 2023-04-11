#!/bin/bash

proxmox_backups="/pooldirectory/dump" # Set this to where your vzdump files are stored
archivedir="/backups/proxmox" #where you want the archive before transferring to Google Drive
rclone_instance="gdrive:" # do not forget the : 

date_now=$(date '+%Y-%m-%d')
logdate=$(date '+%Y-%m-%d %H:%M')


#basic spinner
function display_spinner() {
    local delay=0.1
    local spinstr='|/-\'
    while [ -n "$(ps a | awk '{print $1}' | grep $1)" ]; do
        local temp=${spinstr#?}
        printf " [%c] " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

function archiving_process() {
    echo "$logdate: Started archiving proxmox backups" >> $archivedir/scriptlog$date_now.log
    display_spinner $$ &
    cd $archivedir
    tar zcfP proxmoxbk${date_now}.tar $proxmox_backups/*
    kill $! >/dev/null 2>&1
    echo "$logdate: Archieved!" >> scriptlog$date_now.log
}

function gdrive_sync_yes() {
    declare -g gdrive_sync=false
    gdrive_sync=true
}

function delete_gdrive_backup() {  
    display_spinner $$ &

    rclone ls $rclone_instance/proxmox/ | grep -oE 'proxmoxbk.*\.tar' 2>/dev/null | while read -r tarfile ; do
    tarfile_date=$(echo "$tarfile" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}')

        if [[ "$tarfile_date" != "$date_now" ]] ; then
            
            echo "$logdate: Deleting previous backup and logs from Google Drive..." >> $archivedir/scriptlog$date_now.log
            rclone delete $rclone_instance/proxmox/$tarfile
            kill $! >/dev/null 2>&1
            echo "$logdate: Deleted!" >> $archivedir/scriptlog$date_now.log
            

        else
            
            echo "$logdate: A backup for today is already in Google Drive." >> $archivedir/scriptlog$date_now.log
            gdrive_sync_yes

        fi

    done 
   
}

function clone_to_gdrive() {
    display_spinner $$ &
 
    if [ "$gdrive_sync" = false ] ; then
        echo "$logdate: Cloning archive to Google Drive..." >> $archivedir/scriptlog$date_now.log 
        rclone copy $archivedir/*$date_now.tar $rclone_instance/proxmox/
        echo "$logdate: Cloned!" >> $archivedir/scriptlog$date_now.log

    else
        echo "$logdate: Cloning skipped!" >> $archivedir/scriptlog$date_now.log

    fi

    kill $! >/dev/null 2>&1
}

function clone_logs() {
    rclone copy $archivedir/*$date_now.log $rclone_instance/proxmox/
    echo "$logdate: Uploaded logs in Google Drive!" >> $archivedir/scriptlog$date_now.log
}


for file in $archivedir/proxmoxbk*.tar ; do
    # extract the date from the file name
    file_date=$(echo "$file" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}')

        if [[ ! -f $file ]] ; then

            echo "$logdate: File does not exist! Archiving latest proxmox backups..." >> $archivedir/scriptlog$date_now.log
            
            archiving_process

            delete_gdrive_backup

            clone_to_gdrive

            clone_logs

        elif [[ "$file_date" != "$date_now" ]] ; then

            rm "$file"
            echo "$logdate: Deleted backup file: $file" >> $archivedir/scriptlog$date_now.log

            archiving_process

            delete_gdrive_backup

            clone_to_gdrive

            clone_logs

        else
            echo "$logdate: A backup for today is already done!" >> $archivedir/scriptlog$date_now.log

        fi

done

# delete previous logs
for logs in $archivedir/*.log ; do
    # extract the date from the file name
    logs_date=$(echo "$logs" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}')
        if [[ "$logs_date" != "$date_now" ]]; then
            # delete the old file
            rm "$logs"
            echo "$logdate: Deleted previous logs." >> $archivedir/scriptlog$date_now.log
        fi
done



