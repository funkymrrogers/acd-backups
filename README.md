# acd-backups
Backing up to Amazon Cloud Drive

# Assumptions

Need to backup unecrypted source files to Amazon in an encrypted format
Source files are accessible via NFS, or are local

# Prerequisites

Centos 7 VM, or physical box.
Amazon cloud drive account or trial.

# Introduction

There's a guide @ https://amc.ovh/2015/08/14/mounting-uploading-amazon-cloud-drive-encrypted.html that covers most of the stuff needed, excepting unencrypted source files - and missing some details that seemed useful.

# Prepping a Centos 7 VM

    yum update –y
    yum install python34 –y
    curl -O https://bootstrap.pypa.io/get-pip.py
    chmod +x ./get-pip.py
    python3.4 get-pip.py
    pip3 install --upgrade git+https://github.com/yadayada/acd_cli.git

# acd_cli ACD auth

Visit https://tensile-runway-92512.appspot.com in a web browser, login.
Take oauth_data output and write to /root/.cache/acd_cli/oauth_data

    acd_init
    acd_sync

# Mount source and acd

Example directory will be movies

    mkdir /mnt/movies
    mkdir /mnt/acd
    acd_cli mount /mnt/acd/

Mount @ /mnt/movies, mount read only to be safe

# Mount an encrypted view of source and an unencrypted view of acd:/backups/.1

Initialize your encfs config first, when the first encfs command is selected the encfs.xml file will be generated. After the first time the config file will be referenced for the settings. Keep this config file safe just like the password, you must reproduce it for restores. The password is not stored in the config file, we'll be storing it in another file for convenience.

    mkdir /root/backup-scripts
    acd_cli mkdir /backups/.1
    ENCFS6_CONFIG='/root/backup-scripts/encfs.xml' encfs --reverse /mnt/movies /mnt/.movies
    echo "<password from previous command>" > /root/backup-scripts/enc-passwd
    chmod 500 /root/backup-scripts/enc-passwd
    fusermount -u /mnt/.movies
    cat /root/backup-scripts/enc-passwd | ENCFS6_CONFIG='/root/backup-scripts/encfs.xml' encfs -S --reverse /mnt/movies /mnt/.movies
    cat /root/backup-scripts/enc-passwd | ENCFS6_CONFIG='/root/backup-scripts/encfs.xml' encfs -S /mnt/acd/backups/.1 /mnt/acd-movies

# Backup

Use the example script: https://github.com/funkymrrogers/acd-backups/blob/master/movies.sh

Be sure to edit the varibles if you've chosen a different version of python, or if you've modified any of the locations

# Moving forward

The encfs mount commands must be run at startup, and the `backup.sh` script can also be added to cron.
