#!/bin/bash

# day number in a week: monday is 1 etc.
DAY=$(date +%u)
# path to the snapshot file of the previous backup
# snapshot allows us to create incremental backup
SNAPSHOT_FILE=/home/ves/backups/local/snapshot.file
# path to the backup file
DAILY_FILE="/home/ves/backups/local/latest/daily${DAY}.tar.gz"
# path to the data to be backed up
SOURCE=/home/ves/data/

# make incremental backup according to snapshot file
# snapshot file will be updated to new backup state after creation
tar --listed-incremental=${SNAPSHOT_FILE} \
	-cvzf ${DAILY_FILE} ${SOURCE}
