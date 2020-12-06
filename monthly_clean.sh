#!/bin/bash

# folder with all the backups
BACKUPS_PATH=/home/ves/backups

# count difference in days for two dates
datediffs(){
    d1=$(date -d "$1" +%s)
    d2=$(date -d "$2" +%s)
    return $(( (d1 - d2) /  86400 ))
}

# LOCAL FILES
# enter folder with local files' backups
cd ${BACKUPS_PATH}/local
# foreach folder with backups from the specific weeks
# folder names with backups are named only with date of the full weekly backup
# so we look only for folders with digits
for DIR in $(ls | grep [0-9])
do
	# count how old is the backup
    datediffs $(date +%Y%m%d) $DIR
	# if older than 30 days than remove full weekly and incremental daily backups
    if [ $? -gt 30 ]; then
        rm -R $DIR
    fi
done

# GIT REPOS
# enter git repos backups' folder
cd ${BACKUPS_PATH}/git
# foreach backed up repo
for REPO in $(ls)
do
	# enter folder with backups of specific repo
    cd $REPO
	# foreach weekly folder ..., like for local files
    for DIR in $(ls | grep [0-9])
    do
        datediffs $(date +%Y%m%d) $DIR
        if [ $? -gt 30 ]; then
            rm -R $DIR
        fi
    done

    cd ..
done

# SVN REPOS
# enter svn repos backups' folder
cd ${BACKUPS_PATH}/svn
# foreach repo
for REPO in $(ls)
do
	# enter folder with backups of specific repo
    cd $REPO
	# foreach weekly folder ..., just like for the local files
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

