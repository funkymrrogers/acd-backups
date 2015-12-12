# acd-backups
Backing up to Amazon Cloud Drive

## Assumptions

* Need to backup unecrypted source files to Amazon in an encrypted format
* Source files are accessible via NFS, or are local

## Prerequisites

* Centos 7 VM, or physical box.
* Amazon cloud drive account or trial.

## Introduction

There's a guide @ https://amc.ovh/2015/08/14/mounting-uploading-amazon-cloud-drive-encrypted.html that covers most of the stuff needed, excepting unencrypted source files - and missing some details that seemed useful.

## Backups

### Prepping a Centos 7 VM

    yum update –y
    yum install python34 –y
    curl -O https://bootstrap.pypa.io/get-pip.py
    chmod +x ./get-pip.py
    python3.4 get-pip.py
    pip3 install --upgrade git+https://github.com/yadayada/acd_cli.git

### acd_cli ACD auth

Visit https://tensile-runway-92512.appspot.com in a web browser, login.

Take oauth_data output and write to /root/.cache/acd_cli/oauth_data

    acd_cli init
    acd_cli sync

### Mount source and acd

Example directory will be movies

    mkdir /mnt/movies
    mkdir /mnt/acd
    mkdir /mnt/.movies
    mkdir /mnt/acd-movies
    acd_cli mount /mnt/acd/

Mount @ /mnt/movies, mount read only to be safe

### Mount an encrypted view of source and an unencrypted view of acd:/backups/.1

Initialize your encfs config first, when the first encfs command is selected the encfs.xml file will be generated. After the first time the config file will be referenced for the settings. Keep this config file safe just like the password, you must reproduce it for restores. The password is not stored in the config file, we'll be storing it in another file for convenience.

    mkdir /root/backup-scripts
    acd_cli mkdir /backups/.1
    ENCFS6_CONFIG='/root/backup-scripts/encfs.xml' encfs --reverse /mnt/movies /mnt/.movies
    echo "<password from previous command>" > /root/backup-scripts/enc-passwd
    chmod 500 /root/backup-scripts/enc-passwd
    fusermount -u /mnt/.movies
    cat /root/backup-scripts/enc-passwd | ENCFS6_CONFIG='/root/backup-scripts/encfs.xml' encfs -S --reverse /mnt/movies /mnt/.movies
    cat /root/backup-scripts/enc-passwd | ENCFS6_CONFIG='/root/backup-scripts/encfs.xml' encfs -S /mnt/acd/backups/.1 /mnt/acd-movies

### Performinmg backup

Use the example script: https://github.com/funkymrrogers/acd-backups/blob/master/movies.sh

Be sure to edit the varibles if you've chosen a different version of python, or if you've modified any of the locations

## Restores

### Single file restore
See lessons learned, expect the single (or several) file restore procedure to be cumbersome if the dataset has large numbers of objects in each directory.

If the example in the backup section is followed, everything required for restore is in place - but the target directory does need to be mounted RW.

Mount the target directory RW:

    [root@vmbackup01 mnt]# pwd
    /mnt
    [root@vmbackup01 mnt]# mkdir moviesRW
    [root@vmbackup01 mnt]# mount 10.1.42.6:/mnt/pool0/movies /mnt/moviesRW

Moving to a directory and deleting a testfile to be restored (only part of test restore, actual restore skips this step):

    [root@vmbackup01 mnt]# cd movies/testdir
    [root@vmbackup01 testdir]# ls -la
    total 331
    drwxr-xr-x.    2 root 1002          3 Dec 11 21:47 .
    drwxrwxr-x. 1135 1002 1002       1136 Dec 11 21:46 ..
    -rw-r--r--.    1 root 1002 4294967296 Dec 11 21:48 testfile
    [root@vmbackup01 testdir]# md5sum testfile
    c9a5a6878d97b48cc965c1e41859f034  testfile
    [root@vmbackup01 testdir]# rm testfile
    rm: remove regular file ‘testfile’? y
    [root@vmbackup01 testdir]# ls -la
    total 330
    drwxr-xr-x.    2 root 1002    2 Dec 11 22:35 .
    drwxrwxr-x. 1135 1002 1002 1136 Dec 11 21:46 ..

Moving to the acd unencrypted view, and copying the file out to accomplish the restore. Listing the directories in the /mnt/acd-movies folder incurs a time penalty based on the number of objects in /mnt/acd-movies (see lessons learned). This can be done if the directory structure is unknown, but attempt to avoid by moving directly into the target backup directory as this does not incur a time penalty.

    [root@vmbackup01 testdir]# cd /mnt/acd-movies/testdir
    [root@vmbackup01 testdir]# dd if=testfile of=/mnt/moviesRW/testdir/testfile bs=1M
    4096+0 records in
    4096+0 records out
    4294967296 bytes (4.3 GB) copied, 3690.6 s, 1.2 MB/s
    [root@vmbackup01 testdir]# md5sum /mnt/moviesRW/testdir/testfile
    c9a5a6878d97b48cc965c1e41859f034  /mnt/moviesRW/testdir/testfile

### Entire dataste restore

## TODO

The encfs mount commands must be run at startup, and the `backup.sh` script can also be added to cron. This needs to be incorporated into this doc - including advice on a mount script and having systemd run that on boot, running backup scripts via cron with a simple `flock`

Restores are tricky. With a large dataset the ACD mount is very slow to list files. Some testing needs to be done to illustrate single file, single directory, and whole dataset restore. The single file and directory might reasonably come out of the encfs mount of the acd mount, however a whole dataset restore might use a single `acd_cli download` command writing to the `encfs --reverse` mount.

Pull requests appreciated for the TODO items.

## Lessons Learned

### Listing directories through encfs > ACDFuse > acd is slow
There appears to be a non linear time increase the more files are in a directory, if you've set up exactly per the discussed example this is the `/mnt/acd-movies` unencrypted view that is subject for this lesson.

The following block shows the problem:

    [root@vmbackup01 acd-movies]# time ls -l | wc -l
    1133
    
    real    4m28.186s
    user    0m0.056s
    sys     0m0.108s
    [root@vmbackup01 acd-movies]# cd ../acd-tv/
    [root@vmbackup01 acd-tv]# time ls -l | wc -l
    249
    
    real    0m16.745s
    user    0m0.014s
    sys     0m0.020s

This block shows that listing the directories directly in their encrypted format sees a linear increase in delay, rather than the exponential increase outlined in the problem.

    [root@vmbackup01 acd-tv]# time acdcli ls -l /backups/.1 | wc -l
    1133
    
    real    0m7.663s
    user    0m7.548s
    sys     0m0.116s
    [root@vmbackup01 acd-tv]# time acdcli ls -l /backups/.2 | wc -l
    249
    
    real    0m2.476s
    user    0m2.378s
    sys     0m0.100s

So what are the takeaways?
* Beware of directories with large numbers of objects
  * Consider scripting backups of huge directories with small files as tarball backups to a dedicated backup directory, that is then sent to acd.
  * Single file restores must be done utilizing the slow method, so expect those to be cumbersome if the directory has a large number of objects.
* Whole dataset restores should be done utilizing acdcli directly (will use this lesson to design restore procedure)

### `cp` files through encfs > ACDFuse > acd hangs
Utilizing `cp` to restore large files from the ACDFuse mount produced hangs on CentOS 7. It appears that it doesn't begin flushing large files to disk immediatley. This may work on a system with RAM > file to be restored, and operator patience. This behavior was not explored in depth.

Utilizing `dd` with `bs=1M` did not hang.

So what are the takeaways?
* For now, `dd` will be documented as single file restore method. Please submit pull requests if further testing reveals an easier way to perform a single file restore.

### Backup or archive this is not
A backup in the traditional sense is a point-in-time copy of data to be used for restore. Several point-in-time backups might make up an archive (one definition of archive). Archive can also refer to the practice of de-staging cold data out of the hot data storage...

None of that is being done here.

Once the backup script is run, we can be confident that all of the data on the source dataset is present on ACD - but once the backup script is run again any files that have been deleted will still be present on ACD. There's no versioning built in to this method, so it's not really archiving.

So what are the takeaways?
* If the source data is constantly changing it needs to be captured at a point in time, and then backed up
* Example: A mysql database should be dumped to <table>.<datetime>.sql files, and the dump directory should be backed up. The source database files should not be backed up.
* Example: A directory full of documents, spreadsheets and so on that are constantly changing should be regularly dumped to a .tar.gz file. The .tar.gz file should be placed in a dump directory that is backed up.  
* Some datasets can be backed up directly, these datasets are charachterized by files that are written and never deleted. By virtue of files never being deleted, the backups do produce a latest point-in-time copy - and versioning would add no value as the files are never updated.
* Example: A PVR dataset where TV episodes are recorded from cable, and added as <basedir>/<series>/<season>/<episode> to the dataset. This dataset has files that should only be written once. 
