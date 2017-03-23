#!/bin/bash
if [ $# -ne 3 ]; then
        echo "Usage: $0 db_to_backup user_db pass_db."
        exit 1;
fi

######### CONF ####################
BUCKET=supermonix
NAME=$1
BACKUP_FOLDER=/tmp/backup
#S3_CMD_CONF=/usr/src/script/s3cmd.cfg
S3_CMD=/usr/bin/s3cmd
TAR=/bin/tar
MYSQL_DUMP=/usr/bin/mysqldump
MYSQL_FLAGS="--quick --create-options --single-transaction"
MYSQL_ENDPOINT="172.31.24.170"
MYSQL_UNAME=$2
MYSQL_PASSWD=$3
MYSQL_DB=$1
##################################################################################
ME=$(basename $0)
echo "$(date '+%Y-%m-%d %H:%M') - $ME - INFO - Starting Backup" >&2
if [ ! -d $BACKUP_FOLDER ]; then
    mkdir -p $BACKUP_FOLDER
fi
###################################################################################
#Check and create archive##########################################################
archive_name=$(echo $(date +%Y%m%d_%H%M)"_"$NAME".sql.gz")
if [ -f $BACKUP_FOLDER/$archive_name ]; then
    echo "$(date '+%Y-%m-%d %H:%M') - $ME - ERROR - Backup: $BACKUP_FOLDER/$archive_name already exists" >&2
    exit 1 
fi

#Dump, encrypt and gzip db

echo "$(date '+%Y-%m-%d %H:%M') - $ME - INFO - Starting Dump" >&2
$MYSQL_DUMP -u $MYSQL_UNAME -p$MYSQL_PASSWD -h $MYSQL_ENDPOINT $MYSQL_FLAGS $MYSQL_DB | gzip > $BACKUP_FOLDER/$archive_name
ret=$?
if [ $ret -ne 0 ]; then
    echo "$(date '+%Y-%m-%d %H:%M') - $ME - ERROR - Creating DUMP, $MYSQL_DUMP returned: $ret" >&2
    exit $ret
fi

ls $BACKUP_FOLDER/ | grep $archive_name >>/dev/null
if [ $? -ne 0 ]; then
    echo "$(date '+%Y-%m-%d %H:%M') - $ME - ERROR - the archive: $BACKUP_FOLDER/$archive_name does not exists" >&2
    exit 1
fi
## Clean local Copies"#############################################################
find $BACKUP_FOLDER -mtime +10 -type f -delete


####################################################################################
#Check and sync with s3 #######################################################
echo "$(date '+%Y-%m-%d %H:%M') - $ME - INFO - Syncing $BACKUP_FOLDER with  S3 $BUCKET" >&2
$S3_CMD put $BACKUP_FOLDER/$archive_name s3://$BUCKET/backup/$(hostname -s)/
####################################################################################
###################################################################################
echo "$(date '+%Y-%m-%d %H:%M') - $ME - INFO - Done" >&2
exit 0
####################################################################################
