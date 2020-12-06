#!/bin/bash

# first argument is full path to repo
REPO_DIR=$1
# just the repo's folder name
REPO_NAME=$(basename ${REPO_DIR})
# date for new folder name
DATE=$(date +"%Y%m%d")
# path to all backups for current repo
BACKUP_PATH=/home/ves/backups/svn/${REPO_NAME}
# path to place for this weekly backup
WEEKLY_PATH=/home/ves/backups/svn/${REPO_NAME}/${DATE}
# full path to backup file
WEEKLY_FILE="${WEEKLY_PATH}/weekly.dmp"
# path to symlink with current week folder
LATEST=/home/ves/backups/svn/${REPO_NAME}/latest

# make directory for backups for this repo if it is the first backup of this repo
mkdir ${BACKUP_PATH} &> /dev/null
# create folder for this week's backups
mkdir ${WEEKLY_PATH}

# create full dump file which is basically the repo backup
svnadmin --quiet dump ${REPO_DIR} > ${WEEKLY_FILE}

# remove old symlink
rm -rf ${LATEST}
# and create symlink for this week
ln -s ${WEEKLY_PATH} ${LATEST}

# get current revision number which is used for incremental backup later
# revision number is the number of the last commit in this repo in this moment
CURR_REV=$(svnlook youngest ${REPO_DIR})

# save revision number
echo ${CURR_REV} > ${LATEST}/.info.rev
# save full path to the repo so it can be restored
echo ${REPO_DIR} > ${LATEST}/.source.dir

# enter parent directory of the repo
cd ${REPO_DIR}/..
# save metadata of the repo including files' ownerships and permission
sh /home/ves/backups/svn_metadata.sh ${REPO_NAME} > ${LATEST}/weekly.metadata

# enter this backup folder
cd ${WEEKLY_PATH}
# compress both files of this backup into tar.gz archive
tar -zcf "weekly.tar.gz" --remove-files weekly.dmp weekly.metadata
