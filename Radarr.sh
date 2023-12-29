#!/bin/bash
# Creating the jail for Radarr. Change the name of the jail
JAIL="Radarr"
iocage destroy $JAIL -f
iocage create -n $JAIL -r 13.2-RELEASE interfaces="vnet0:bridge0" defaultrouter="none" vnet="on" dhcp="on" bpf="yes" allow_raw_sockets="1" allow_mlock="1" boot="on"
iocage update $JAIL
iocage set enforce_statfs=1 $JAIL

# Updating the source to the latest repo
iocage exec $JAIL "mkdir -p /usr/local/etc/pkg/repos"
iocage exec $JAIL "echo 'FreeBSD: {url: \"pkg+http://pkg.FreeBSD.org/\${ABI}/latest\"}' > /usr/local/etc/pkg/repos/FreeBSD.conf"
iocage exec $JAIL pkg update

# Installing radarr and dependencies
iocage exec $JAIL pkg install -y radarr

# Mounting storage and config
iocage exec $JAIL mkdir -p /config
iocage exec $JAIL mkdir -p /mnt/Movies
iocage exec $JAIL mkdir -p /mnt/Torrents
iocage exec $JAIL mkdir -p /mnt/Import
mkdir /mnt/Tank/Backup/Jailconfig/$JAIL
iocage fstab -a $JAIL /mnt/Tank/Backup/Jailconfig/$JAIL /config nullfs rw 0 0
iocage fstab -a $JAIL /mnt/Tank/Movies /mnt/Movies nullfs rw 0 0
iocage fstab -a $JAIL /mnt/Tank/Torrents /mnt/Torrents nullfs rw 0 0
iocage fstab -a $JAIL /mnt/Tank/Import /mnt/Import nullfs rw 0 0

# Creating multimedia group and add radarr user to group multimedia in jail
iocage exec $JAIL "pw groupadd multimedia -g 816"
iocage exec $JAIL "pw usermod radarr -G multimedia"

# Changing ownership to folders
iocage exec $JAIL chown -R radarr:multimedia /config
iocage exec $JAIL chown -R radarr:multimedia /mnt/Movies
#iocage exec $JAIL chown -R radarr:multimedia /mnt/Torrents
#iocage exec $JAIL chown -R radarr:multimedia /mnt/Import


#iocage exec $JAIL vi /usr/local/etc/rc.d/radarr
iocage exec $JAIL sysrc "radarr_enable=TRUE"
#iocage exec $JAIL sysrc radarr_user=radarr
iocage exec $JAIL sysrc radarr_group=multimedia
iocage exec $JAIL sysrc radarr_data_dir="/config"
iocage exec $JAIL service radarr start
