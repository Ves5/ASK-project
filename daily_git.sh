#!/bin/bash

# first argument is full path to repo
REPO_DIR=$1
# only repo's folder name
REPO_NAME=$(basename ${REPO_DIR})
# day number in the week, monday is 1 etc.
DAY=$(date +%u)
# path where this backup should be placed
DAILY_PATH=/home/ves/backups/git/${REPO_NAME}/latest
# full path of the file of this backup
DAILY_FILE="${DAILY_PATH}/daily${DAY}.bundle"
# tag which allows incremental backups
BACKUP_TAG="lastBackup"

# enter git repo folder
cd ${REPO_DIR}

# if there were no commits since last backup
# at lower level: if there were no commits since tag created with the previous backup
if [ $(git log ${BACKUP_TAG}..master --oneline | wc -l) -eq 0 ]; then
	# then nothing to do
	exit
fi

# create incremental bundle aka backup which includes only changes since previous backup
git bundle create ${DAILY_FILE} --all ${BACKUP_TAG}..master

# create the tag with the same name, so it is updated to current backup
git tag -f ${BACKUP_TAG} master

# save metadata: files' ownerships and permission
sh /home/ves/backups/git_metadata.sh > ${DAILY_PATH}/daily${DAY}.metadata

# enter backup folder
cd ${DAILY_PATH}
# and compress both files into tar.gz archive
tar -zcf "daily${DAY}.tar.gz" --remove-files daily${DAY}.bundle daily${DAY}.metadata
