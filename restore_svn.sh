#!/bin/bash

REPO_NAME=$1

# symlink to latest weekly and daily backups
LATEST=/home/ves/backups/svn/${REPO_NAME}/latest

# count difference in days for two dates
datediffs(){
    d1=$(date -d "$1" +%s)
    d2=$(date -d "$2" +%s)
    return $(( (d1 - d2) /  86400 ))
}

# if user doesn't provide the date, restore latest backup
if [ $# -eq 1 ]; then
    cd $LATEST

    DEST=$(cat .source.dir)

    cd $DEST

    rm -R $REPO_NAME &> /dev/null

    # extract latest weekly (full) backup
    tar --listed-incremental=/dev/null -xvf ${LATEST}/weekly.tar.gz

    svnadmin create $REPO_NAME

    svnadmin load $REPO_NAME < weekly.dmp

    sh weekly.metadata &> /dev/null

    rm weekly.dmp weekly.metadata

    # extracting each daily incremental backup
    for INC in $(ls ${LATEST}/daily*)
    do
        tar --listed-incremental=/dev/null -xvf $INC

        INC=$(basename $INC | cut -d. -f1)

        svnadmin load $REPO_NAME < "$INC.dmp"

        sh "$INC.metadata" &> /dev/null

        rm "$INC.dmp" "$INC.metadata"
    done
elif [ $# -eq 2 ]; then
    cd $LATEST/..

    # find latest full backup with all increments
    for DIR in $(ls -r | grep [0-9])
    do
        # find first smaller or equal date than given by user
        if [ $DIR -le $(date -d "$2" +%Y%m%d) ]; then
            cd $DIR

            SOURCE=/home/ves/backups/git/${REPO_NAME}/${DIR}

            DEST=$(cat .source.dir)

            cd $DEST

            rm -R $REPO_NAME &> /dev/null

            # extract latest weekly (full) backup
            tar --listed-incremental=/dev/null -xvf ${SOURCE}/weekly.tar.gz

            svnadmin create $REPO_NAME

            svnadmin load $REPO_NAME < weekly.dmp

            sh weekly.metadata &> /dev/null

            rm weekly.bundle weekly.metadata

            datediffs $2 $DIR
            COUNT=$(($? + 1))
            
            for DAY in $(ls ${SOURCE}/daily*)
            do
                if [ $COUNT -lt $(basename $DAY | head -c 6 | tail -c 1) ]; then
                    break
                fi

                tar --listed-incremental=/dev/null -xvf $DAY

                DAY=$(basename $DAY | cut -d. -f1)

                svnadmin load $REPO_NAME < "$DAY.dmp"

                sh "$DAY.metadata" &> /dev/null

                rm "$DAY.dmp" "$DAY.metadata"
            done
            break
        fi
    done
fi