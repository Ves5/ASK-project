#!/bin/bash

REPO_DIR=$1
REPO_NAME=$(basename ${REPO_DIR})
DAY=$(date +%u)
DAILY_PATH=/home/ves/backups/git/${REPO_NAME}/latest
DAILY_FILE="${DAILY_PATH}/daily${DAY}.bundle"
BACKUP_TAG="lastBackup"

cd ${REPO_DIR}

if [ $(git log ${BACKUP_TAG}..master --oneline | wc -l) -eq 0 ]; then	
	exit
fi

git bundle create ${DAILY_FILE} --all ${BACKUP_TAG}..master

git tag -f ${BACKUP_TAG} master

echo ${REPO_DIR} > ${DAILY_PATH}/.source.dir
sh /home/ves/backups/git_metadata.sh > ${DAILY_PATH}/daily${DAY}.metadata

cd ${DAILY_PATH}
tar -zcf "daily${DAY}.tar.gz" --remove-files daily${DAY}.bundle daily${DAY}.metadata
