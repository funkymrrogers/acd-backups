#!/bin/bash
# This script will upload all files in $local_location to Amazon Cloud Drive using acd_cli to $remote_location
# It will skip already uploaded files by comparing hashes
# Original https://github.com/dcplaya/acd_cli-BackupScripts/blob/master/Movies_Upload.sh from David Carpenter
# Updated for python3.4

#Set to true if you want to run acd_cli with verbose
verbose=true

#Set location of acd_cli
acd_cli=/usr/bin/acd_cli.py

#Set local location of files to upload. Everything in this folder will be uploaded but no the folder itself
local_location=/mnt/.movies/

#Set remote location on ACD
remote_location=/backups/.1/

#Set location of where to store log file as well as the name
log_location=/root/backup-scripts/movies-upload.log

# Start of actual code!
################################################################################################################################################
#Sync to make sure we have the most up to date file structure

acd_sync

if [ "$verbose" == true ]
then
        echo "Verbose enabled!"
        python3.4 "$acd_cli" -v sync                                                                            # Syncs with ACD before uploading to make sure we have the most up to date info
        python3.4 "$acd_cli" -v upload -x 4 "$local_location"* "$remote_location" 2> >(tee "$log_location" >&2) # Starts uploading with the locations set at the top of this script
else
        python3.4 "$acd_cli" -v sync                                                                            # Syncs with ACD before uploading to make sure we have the most up to date info
        python3.4 "$acd_cli" -v upload -x 4 "$local_location"* "$remote_location"                                       # Starts uploading with the locations set at the top of this script
fi

exit 0
