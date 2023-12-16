#!/bin/bash
# Creating the jail for Radarr. Change the name of the jail
JAIL="Radarr"
iocage create -n $JAIL -r 13.2-RELEASE interfaces="vnet0:bridge0" defaultrouter="none" vnet="on" dhcp="on" bpf="yes" allow_raw_sockets="1" allow_mlock="1" boot="on"
iocage update $JAIL

# Updating the source to the latest repo
iocage exec $JAIL "mkdir -p /usr/local/etc/pkg/repos"
iocage exec $JAIL "echo 'FreeBSD: {url: \"pkg+http://pkg.FreeBSD.org/\${ABI}/latest\"}' > /usr/local/etc/pkg/repos/FreeBSD.conf"
iocage exec $JAIL pkg update -y

# Installing radarr and dependencies
iocage exec $JAIL pkg install -y radarr

# Mounting storage and config
iocage exec $JAIL mkdir -p /config
iocage exec $JAIL mkdir -p /media/Movies
iocage exec $JAIL mkdir -p /media/Torrents
iocage exec $JAIL mkdir -p /media/Import
mkdir /mnt/Tank/Backup/Jailconfig/$JAIL
iocage fstab -a $JAIL /mnt/Tank/Backup/Jailconfig/$JAIL /config nullfs rw 0 0
iocage fstab -a $JAIL /mnt/Tank/Movies /media/Movies nullfs rw 0 0
iocage fstab -a $JAIL /mnt/Tank/Torrents /media/Torrents nullfs rw 0 0
iocage fstab -a $JAIL /mnt/Tank/Import /media/Import nullfs rw 0 0

# Creating media group and add radarr user to group
iocage exec $JAIL "pw groupadd media -g 816"
iocage exec $JAIL "pw usermod radarr -G media"

# Changing ownership to folders
iocage exec $JAIL chown -R radarr:media /config
#iocage exec $JAIL chown -R radarr:media /media/Movies
#iocage exec $JAIL chown -R radarr:media /media/Torrents
#iocage exec $JAIL chown -R radarr:media /media/Import


#iocage exec radarr vi /usr/local/etc/rc.d/radarr
iocage exec $JAIL sysrc "radarr_enable=TRUE"
#iocage exec $JAIL sysrc radarr_user=radarr
iocage exec $JAIL sysrc radarr_group=media
iocage exec $JAIL sysrc radarr_data_dir="/config"
iocage exec $JAIL service radarr start
