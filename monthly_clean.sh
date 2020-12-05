#!/bin/bash

BACKUPS_PATH=/home/ves/backups

datediffs(){
    d1=$(date -d "$1" +%s)
    d2=$(date -d "$2" +%s)
    return $(( (d1 - d2) /  86400 ))
}

# local
cd ${BACKUPS_PATH}/local

for DIR in $(ls | grep [0-9])
do
    datediffs $(date +%Y%m%d) $DIR
    if [ $? -gt 30 ]; then
        rm -R $DIR
    fi
done

# git

cd ${BACKUPS_PATH}/git

for REPO in $(ls)
do
    cd $REPO

    for DIR in $(ls | grep [0-9])
    do
        datediffs $(date +%Y%m%d) $DIR
        if [ $? -gt 30 ]; then
            rm -R $DIR
        fi
    done

    cd ..
done

# svn 

cd ${BACKUPS_PATH}/svn

for REPO in $(ls)
do
    cd $REPO

    for DIR in $(ls | grep [0-9])
    do
        datediffs $(date +%Y%m%d) $DIR
        if [ $? -gt 30 ]; then
            rm -R $DIR
        fi
    done

    cd ..
done

# 

