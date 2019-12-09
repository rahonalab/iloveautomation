#!/bin/bash
if [ $# -ne 1 ]; then
        echo "Usage: $0 site_to_backup. E.g., $0 yoursite"
        exit 1;
fi


######### conf ####################
bucket=randsolutions-backup
backup_folder=/tmp/sites/
s3_cmd_conf=/root/.s3cfg
s3_cmd=/usr/bin/s3cmd
tar=/bin/tar
local_copies=3

#env=$(echo $(hostname -s) | cut -d'-' -f3)
env=$(echo $(hostname -s))
folder=$1				
appname=$(basename $(dirname $(readlink -f $folder)))_$(basename $folder)
archive_name=$(date +%Y%m%d_%H%M)_${appname}_${env}.tgz
##################################################################################
ME=$(basename $0)
echo "$(date '+%Y-%m-%d %H:%M') - $ME - INFO - Starting Backup" >&2
[ ! -d $backup_folder ] && mkdir -p $backup_folder
###################################################################################
#Check and create archive##########################################################
to_backup=$(readlink -f $folder)
if [ ! -d $to_backup ]; then
    echo "$(date '+%Y-%m-%d %H:%M') - $ME - ERROR - Folder: $to_backup does not exist" >&2
    exit 1
fi

if [ -f $backup_folder/$archive_name ]; then
    echo "$(date '+%Y-%m-%d %H:%M') - $ME - ERROR - Backup: $backup_folder/$archive_name already exists" >&2
    exit 1 
fi

echo "$(date '+%Y-%m-%d %H:%M') - $ME - INFO - Creating backup: $backup_folder/$archive_name" >&2
$tar czvf $backup_folder/$archive_name $to_backup >>/dev/null 2>&1
ret=$?
if [ $ret -ne 0 ]; then
    echo "$(date '+%Y-%m-%d %H:%M') - $ME - ERROR - Creating backup, $tar returned: $ret" >&2
    exit $ret
fi
ls $backup_folder/ | grep $archive_name >>/dev/null
if [ $? -ne 0 ]; then
    echo "$(date '+%Y-%m-%d %H:%M') - $ME - ERROR - the archive: $backup_folder/$archive_name does not exist" >&2
    exit 1
fi

## Clean local Copies"#############################################################
echo "$(date '+%Y-%m-%d %H:%M') - $ME - INFO - Creating backup: Deleting copies old than $local_copies days from $backup_folder" >&2
find $backup_folder -mtime +$local_copies -type f -delete

########

####################################################################################
#Check and sync files with s3 #######################################################
s3_file=s3://${bucket}/${env}/
$s3_cmd -c $s3_cmd_conf ls s3://$bucket/${env}/* | grep $archive_name >>/dev/null 2>&1
if [[ $? -eq 0 ]]; then
    echo "$(date '+%Y-%m-%d %H:%M') - $ME - ERROR - File:$archive_name already exists in  s3://$bucket/${env}/" >&2
    exit 1
fi
echo "$(date '+%Y-%m-%d %H:%M') - $ME - INFO - Sync backup folder with S3: $s3_file" >&2
$s3_cmd sync --no-check-md5 --delete-removed $backup_folder $s3_file >>/dev/null 2>&1
ret=$?
if [ $ret -ne 0 ]; then
    echo "$(date '+%Y-%m-%d %H:%M') - $ME - ERROR - $s3_cmd returned: $ret" >&2
    exit $ret
fi
$s3_cmd -c $s3_cmd_conf ls s3://$bucket/$env/* | grep $archive_name >>/dev/null 2>&1
if [[ $? -ne 0 ]]; then
    echo "$(date '+%Y-%m-%d %H:%M') - $ME - ERROR - File:$s3_file does not exist in  s3://$bucket/$env/" >&2
    exit 1
fi

###########################################################################
echo "$(date '+%Y-%m-%d %H:%M') - $ME - INFO - Done" >&2
exit 0
####################################################################################
