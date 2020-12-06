#!/bin/bash

# used as folder name
DATE=$(date +"%Y%m%d")
# snapshot file includes information for incremental backups
SNAPSHOT_FILE=/home/ves/backups/local/snapshot.file
# path for backups for current week
WEEKLY_PATH=/home/ves/backups/local/${DATE}
# path for full backup file which is weekly file
WEEKLY_FILE="${WEEKLY_PATH}/weekly.tar.gz"
# path to the data which should be backed up
SOURCE=/home/ves/data/
# symlink to be created for backup folder for current week
LATEST=/home/ves/backups/local/latest

# remove old snapshot file, so this backup will be the full backup
rm -rf ${SNAPSHOT_FILE}
# create directory for current week
mkdir ${WEEKLY_PATH}
# make full backup with tar command
# this command also create snapshot file with info
# about this backup needed for next incremental backup
tar --listed-incremental=${SNAPSHOT_FILE} \
	-cvzf ${WEEKLY_FILE} ${SOURCE}

# remove old symlink to latest folder (folder for previous week)
rm -rf ${LATEST}
# create new symlink which points to current week folder
ln -s ${WEEKLY_PATH} ${LATEST}
