#!/bin/bash

DAY=$(date +%u)
SNAPSHOT_FILE=/home/ves/backups/local/snapshot.file
DAILY_FILE="/home/ves/backups/local/latest/daily${DAY}.tar.gz"
SOURCE=/home/ves/data/

tar --listed-incremental= ${SNAPSHOT_FILE} \
	-cvzf ${DAILY_FILE} ${SOURCE}
