#!/bin/bash

source backup.sh


function restore() {
    rclone ls $rclone_instance/proxmox/ | grep -oE 'proxmoxbk.*.tar' 2>/dev/null | while read -r tar ; do
    rclone copy $rclone_instance/proxmox/$tar $proxmox_backups
    cd $proxmox_backups
    tar xvf $tar
    rm $tar
    done
}

restore

