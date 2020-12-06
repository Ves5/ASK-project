#!/bin/bash

# first argument is full path to repo
REPO_DIR=$1
# extract just the folder name with the repo
REPO_NAME=$(basename ${REPO_DIR})
# number of the day in the week for the backup name
DAY=$(date +%u)
# path where backup should be placed
DAILY_PATH=/home/ves/backups/svn/${REPO_NAME}/latest
# full path of the dump file to create
DAILY_FILE="${DAILY_PATH}/daily${DAY}.dmp"

# get last commit number for previous backup
# and increment it by one
# this variable have the first commit number which should be backed up in this backup
OLD_REV=$(($(cat ${DAILY_PATH}/.info.rev) + 1))

# get current revision number in the repo
CURR_REV=$(svnlook youngest ${REPO_DIR})

# if there were no backups since the previous backup
if [ ${OLD_REV} -gt ${CURR_REV} ]; then
	# then nothing to do in this script
	echo "No changes to repository"
	exit
fi

# create incremental dump (aka backup) for all commits since previous backup
svnadmin --quiet dump ${REPO_DIR} --incremental -r ${OLD_REV}:${CURR_REV} > ${DAILY_FILE}

# save current commit number for next incremental backup
echo ${CURR_REV} > ${DAILY_PATH}/.info.rev

# enter repos parent directory
cd ${REPO_DIR}/..
# save required metadata of the files in the repo
sh /home/ves/backups/svn_metadata.sh ${REPO_NAME} > ${LATEST}/weekly.metadata

# enter path where the backup is
cd ${DAILY_PATH}
# and compress both files into tar.gz archive
tar -zcf "daily${DAY}.tar.gz" --remove-files daily${DAY}.dmp daily${DAY}.metadata
