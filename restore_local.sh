#!/bin/bash

# symlink to latest weekly and daily backups
LATEST=/home/ves/backups/local/latest

# count difference in days for two dates
datediffs(){
    d1=$(date -d "$1" +%s)
    d2=$(date -d "$2" +%s)
    return $(( (d1 - d2) /  86400 ))
}

# if user doesn't provide the date, restore latest backup
if [ $# -eq 0 ]; then
    # enter the directory with the most recent backup
	cd $LATEST

    # extract latest weekly (full) backup
    tar --listed-incremental=/dev/null -C / -xvf weekly.tar.gz

    # extracting each daily incremental backup
    for INC in $(ls daily*)
    do
        tar --listed-incremental=/dev/null -C / -xvf $INC
    done
else
	# enter directory where are all week packs of backups
    cd $LATEST/..

    # find full backup with all increments which is the most recent relative to given date
    for DIR in $(ls -r | grep [0-9])
    do
        # find first smaller or equal date than given by user
        if [ $DIR -le $(date -d "$1" +%Y%m%d) ]; then
			# if true, than enter the directory which is the folder with needed backup
            cd $DIR
			
			# extract weekly full backup
            tar --listed-incremental=/dev/null -C / -xvf weekly.tar.gz
			
			# calculate number of days between weekly backup and given date
            datediffs $1 $DIR
            COUNT=$(($? + 1))
            # extract daily backups up to the date given by the user
            for DAY in $(ls daily* | head -"$COUNT")
            do
                tar --listed-incremental=/dev/null -C / -xvf $DAY
            done
            break
        fi
    done
fi
