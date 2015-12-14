acd_cli sync
acd_cli mount /mnt/acd/

# Duplicate the following two lines for each backup dataset
cat /root/backup-scripts/enc-passwd | ENCFS6_CONFIG='/root/backup-scripts/encfs.xml' encfs -S --reverse /mnt/movies /mnt/.movies
cat /root/backup-scripts/enc-passwd | ENCFS6_CONFIG='/root/backup-scripts/encfs.xml' encfs -S /mnt/acd/backups/.1 /mnt/acd-movies
