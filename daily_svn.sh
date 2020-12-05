#!/bin/bash

REPO_DIR=$1
REPO_NAME=$(basename ${REPO_DIR})
DAY=$(date +%u)
DAILY_PATH=/home/ves/backups/svn/${REPO_NAME}/latest
DAILY_FILE="${DAILY_PATH}/daily${DAY}.dmp"

OLD_REV=$(($(cat ${DAILY_PATH}/.info.rev) + 1))

CURR_REV=$(svnlook youngest ${REPO_DIR})

if [ ${OLD_REV} -gt ${CURR_REV} ]; then
	echo "No changes to repository"
	exit
fi

svnadmin --quiet dump ${REPO_DIR} --incremental -r ${OLD_REV}:${CURR_REV} > ${DAILY_FILE}

echo ${CURR_REV} > ${DAILY_PATH}/.info.rev
echo ${REPO_DIR} > ${DAILY_PATH}/.source.dir

cd ${REPO_DIR}/..
sh /home/ves/backups/svn_metadata.sh ${REPO_NAME} > ${LATEST}/weekly.metadata

cd ${DAILY_PATH}
tar -zcf "daily${DAY}.tar.gz" --remove-files daily${DAY}.dmp daily${DAY}.metadata