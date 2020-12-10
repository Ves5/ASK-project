#!/bin/bash

REPO_NAME=$1

# symlink to latest weekly and daily backups
LATEST=/home/ves/backups/git/${REPO_NAME}/latest

# count difference in days for two dates
datediffs(){
    d1=$(date -d "$1" +%s)
    d2=$(date -d "$2" +%s)
    return $(( (d1 - d2) /  86400 ))
}

# if user doesn't provide the date, restore latest backup
if [ $# -eq 1 ]; then
    # folder with the latest backups' pack
	cd $LATEST

	# destination for the repo from backup
    DEST=$(cat .source.dir)
	# go to desitnation folder
    cd $DEST
	# remove this repo on place to make place for the backed up one
    rm -R $REPO_NAME &> /dev/null

    # extract latest weekly (full) backup
    tar --listed-incremental=/dev/null -xvf ${LATEST}/weekly.tar.gz
	# create repo from full weekly bundle
    git clone weekly.bundle $REPO_NAME
	# enter repo
    cd $REPO_NAME
	# add metadata to all files (file permissions and ownerships)
    sh ../weekly.metadata &> /dev/null
	# clean the old files
    rm ../weekly.bundle ../weekly.metadata

    # extracting each daily incremental backup
    for INC in $(ls ${LATEST}/daily*)
    do	
		# extract daily backups
        tar --listed-incremental=/dev/null -xvf $INC

        INC=$(basename $INC | cut -d. -f1)
		# put changes from incrementall backup into repo
        git pull "$INC.bundle"
		# update metadata to current required state
        sh "$INC.metadata" &> /dev/null
		# clean files
        rm "$INC.bundle" "$INC.metadata"
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
			# remove repo form destination place to make place for backup
            rm -R $REPO_NAME &> /dev/null

            # extract latest weekly (full) backup
            tar --listed-incremental=/dev/null -xvf ${SOURCE}/weekly.tar.gz
			# put full backup into repo
            git clone weekly.bundle $REPO_NAME

            cd $REPO_NAME
			# update metadata
            sh ../weekly.metadata &> /dev/null
			# clean backup files
            rm ../weekly.bundle ../weekly.metadata
			# count daily bakcup limit to restore
            datediffs $2 $DIR
            COUNT=$(($? + 1))
            
			# resotre daily backups
            for DAY in $(ls ${SOURCE}/daily*)
            do	
				# if daily backup was further in the future than given date then stop daily restores
                if [ $COUNT -lt $(basename $DAY | head -c 6 | tail -c 1) ]; then
                    break
                fi
				
				# extract daily backup files
                tar --listed-incremental=/dev/null -xvf $DAY
				
                DAY=$(basename $DAY | cut -d. -f1)
				# put incremental changes in repo
                git pull "$DAY.bundle"
				# update metadata
                sh "$DAY.metadata" &> /dev/null
				# clean files
                rm "$DAY.bundle" "$DAY.metadata"
            done
            break
        fi
    done
fi
