#!/bin/bash

DATE=$(date +"%Y%m%d")
SNAPSHOT_FILE=/home/ves/backups/local/snapshot.file
WEEKLY_PATH=/home/ves/backups/local/${DATE}
WEEKLY_FILE="${WEEKLY_PATH}/weekly.tar.gz"
SOURCE=/home/ves/data/
LATEST=/home/ves/backups/local/latest

rm -rf ${SNAPSHOT_FILE}
mkdir ${WEEKLY_PATH}
tar --listed-incremental=${SNAPSHOT_FILE} \
	-cvzf ${WEEKLY_FILE} ${SOURCE}
rm -rf ${LATEST}
ln -s ${WEEKLY_PATH} ${LATEST}
