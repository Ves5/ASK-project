#!/bin/bash

# first argument is the full path to the repo
REPO_DIR=$1
# just the folder name of the repo
REPO_NAME=$(basename ${REPO_DIR})
# today date for the folder name
DATE=$(date +"%Y%m%d")
# path to the folder with backups for current repo
BACKUP_PATH=/home/ves/backups/git/${REPO_NAME}
# path for the backups for this new week
WEEKLY_PATH=/home/ves/backups/git/${REPO_NAME}/${DATE}
# path to the full weekly backup git file
WEEKLY_FILE="${WEEKLY_PATH}/weekly.bundle"
# tags are used to perform incremental backups
BACKUP_TAG="lastBackup"
# path to the symlink for 
LATEST=/home/ves/backups/git/${REPO_NAME}/latest

# create folder for the backups for this repo if this is the first backup for this repo
mkdir ${BACKUP_PATH} &> /dev/null
# create folder for current week's backups
mkdir ${WEEKLY_PATH} &> /dev/null

# enter git repository to be backed up
cd ${REPO_DIR}

# create bundle which is basically full backup of the repo
git bundle create ${WEEKLY_FILE} --all

# make tag for current state of the repo
git tag -f ${BACKUP_TAG} master

# delete previous week's symlink
rm -rf ${LATEST}
# and recreate for the current week
ln -s ${WEEKLY_PATH} ${LATEST}

# save the full path to repo so it can be recreated in proper place
echo $(dirname ${REPO_DIR}) > ${LATEST}/.source.dir
# save metadata which include files' ownerships, permission
sh /home/ves/backups/git_metadata.sh > ${LATEST}/weekly.metadata

# enter backups' path
cd ${WEEKLY_PATH}
# compress bundle and metadata into tar.gz
tar -zcf "weekly.tar.gz" --remove-files weekly.bundle weekly.metadata
