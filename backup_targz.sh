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
####################################################################################
#Check and upload file to s3 #######################################################
s3_file=s3://${bucket}/${env}/
$s3_cmd -c $s3_cmd_conf ls s3://$bucket/${env}/* | grep $archive_name >>/dev/null 2>&1
if [[ $? -eq 0 ]]; then
    echo "$(date '+%Y-%m-%d %H:%M') - $ME - ERROR - File:$archive_name already exists in  s3://$bucket/${env}/" >&2
    exit 1
fi
echo "$(date '+%Y-%m-%d %H:%M') - $ME - INFO - Uploading backup to S3: $s3_file" >&2
$s3_cmd sync --delete-removed $backup_folder $s3_file >>/dev/null 2>&1
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
####################################################################################
## Clean local Copies#############################################################
number_of_copies=$(ls -l $backup_folder/ | grep $appname | wc -l)
if [ $number_of_copies -gt $local_copies ]; then
    let number_of_copies_to_clean=number_of_copies-local_copies+1
    echo "$(date '+%Y-%m-%d %H:%M') - $ME - INFO - Cleaning $number_of_copies_to_clean local copies" >&2
    while [ $number_of_copies_to_clean -gt 0 ]; do
        file_to_clean=$(ls -rt $backup_folder/ | grep $env |  head -n1)
        echo "$(date '+%Y-%m-%d %H:%M') - $ME - INFO - Cleaning $backup_folder/$file_to_clean" >&2
        rm -f $backup_folder/$file_to_clean
        let number_of_copies_to_clean=number_of_copies_to_clean-1
    done
fi
###################################################################################
echo "$(date '+%Y-%m-%d %H:%M') - $ME - INFO - Done" >&2
exit 0
####################################################################################
