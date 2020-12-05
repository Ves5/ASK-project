#!/bin/bash
REPO_DIR=$1
REPO_NAME=$(basename ${REPO_DIR})
DATE=$(date +"%Y%m%d")
BACKUP_PATH=/home/ves/backups/git/${REPO_NAME}
WEEKLY_PATH=/home/ves/backups/git/${REPO_NAME}/${DATE}
WEEKLY_FILE="${WEEKLY_PATH}/weekly.bundle"
BACKUP_TAG="lastBackup"
LATEST=/home/ves/backups/git/${REPO_NAME}/latest

mkdir ${BACKUP_PATH} &> /dev/null
mkdir ${WEEKLY_PATH} &> /dev/null

# enter git repository
cd ${REPO_DIR}

git bundle create ${WEEKLY_FILE} --all

git tag -f ${BACKUP_TAG} master

rm -rf ${LATEST}
ln -s ${WEEKLY_PATH} ${LATEST}

echo ${REPO_DIR} > ${LATEST}/.source.dir
sh /home/ves/backups/git_metadata.sh > ${LATEST}/weekly.metadata

cd ${WEEKLY_PATH}
tar -zcf "weekly.tar.gz" --remove-files weekly.bundle weekly.metadata
