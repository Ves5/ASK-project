#!/bin/bash
REPO_DIR=$1
REPO_NAME=$(basename ${REPO_DIR})
DATE=$(date +"%Y%m%d")
BACKUP_PATH=/home/ves/backups/svn/${REPO_NAME}
WEEKLY_PATH=/home/ves/backups/svn/${REPO_NAME}/${DATE}
WEEKLY_FILE="${WEEKLY_PATH}/weekly.dmp"
BACKUP_TAG="lastBackup"
LATEST=/home/ves/backups/svn/${REPO_NAME}/latest

mkdir ${BACKUP_PATH} &> /dev/null
mkdir ${WEEKLY_PATH}

svnadmin --quiet dump ${REPO_DIR} > ${WEEKLY_FILE}

rm -rf ${LATEST}
ln -s ${WEEKLY_PATH} ${LATEST}

CURR_REV=$(svnlook youngest ${REPO_DIR})

echo ${CURR_REV} > ${LATEST}/.info.rev
echo ${REPO_DIR} > ${LATEST}/.source.dir

cd ${REPO_DIR}/..
sh /home/ves/backups/svn_metadata.sh ${REPO_NAME} > ${LATEST}/weekly.metadata

cd ${WEEKLY_PATH}
tar -zcf "weekly.tar.gz" --remove-files weekly.dmp weekly.metadata
