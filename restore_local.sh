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
    cd $LATEST

    # extract latest weekly (full) backup
    tar --listed-incremental=/dev/null -C / -xvf weekly.tar.gz

    # extracting each daily incremental backup
    for INC in $(ls daily*)
    do
        tar --listed-incremental=/dev/null -C / -xvf $INC
    done
else
    cd $LATEST/..

    # find latest full backup with all increments
    for DIR in $(ls -r | grep [0-9])
    do
        # find first smaller or equal date than given by user
        if [ $DIR -le $(date -d "$1" +%Y%m%d) ]; then
            cd $DIR

            tar --listed-incremental=/dev/null -C / -xvf weekly.tar.gz

            datediffs $1 $DIR
            COUNT=$(($? + 1))
            
            for DAY in $(ls daily* | head -"$COUNT")
            do
                tar --listed-incremental=/dev/null -C / -xvf $DAY
            done
            break
        fi
    done
fi