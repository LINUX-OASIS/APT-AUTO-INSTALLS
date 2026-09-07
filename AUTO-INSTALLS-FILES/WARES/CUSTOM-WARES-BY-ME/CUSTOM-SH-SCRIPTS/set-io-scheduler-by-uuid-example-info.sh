#!/bin/bash

# List of UUIDs (one per line)
# For each drive: Add the UUID of a single partition located on the drive of which you want to change the I/O-scheduler
UUID_LIST=(
    2669b09e-75cd-4f45-bedb-8cb405444287
)

DISK_PATH="/dev/disk/by-uuid"
BLOCK_PATH="/sys/block"

for UUID in ${UUID_LIST[@]} ; do
    if [[ -L "${DISK_PATH}/${UUID}" ]] ; then
        TARGET=$( readlink "${DISK_PATH}/${UUID}" )
        DISK=`expr "${TARGET}" : '.*\(sd[a-z]\)'`

        if [[ -d "${BLOCK_PATH}/${DISK}" ]] ; then
            echo deadline > "${BLOCK_PATH}/${DISK}/queue/scheduler"
            echo 1 > "${BLOCK_PATH}/${DISK}/queue/iosched/fifo_batch"
        fi
    fi
done

