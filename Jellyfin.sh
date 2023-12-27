#!/bin/bash
# Creating the jail for Jellyfin. Change the name of the jail
JAIL="Jellyfin"
iocage create -n $JAIL -r 13.2-RELEASE interfaces="vnet0:bridge0" defaultrouter="none" vnet="on" dhcp="on" bpf="yes" allow_raw_sockets="1" allow_mlock="1" boot="on"
iocage update $JAIL
iocage set enforce_statfs=1 $JAIL

# Updating the source to the latest repo
iocage exec $JAIL "mkdir -p /usr/local/etc/pkg/repos"
iocage exec $JAIL "echo 'FreeBSD: {url: \"pkg+http://pkg.FreeBSD.org/\${ABI}/latest\"}' > /usr/local/etc/pkg/repos/FreeBSD.conf"
#iocage exec $JAIL "echo 'FreeBSD: {url: \"pkg+http://pkg.FreeBSD.org/\${ABI}/quarterly\"}' > /usr/local/etc/pkg/repos/FreeBSD.conf"
iocage exec $JAIL pkg update

# Installing jellyfin and dependencies
iocage exec $JAIL pkg install -y jellyfin nano

# Mounting storage and config
iocage exec $JAIL mkdir -p /config
iocage exec $JAIL mkdir -p /mnt/Movies
iocage exec $JAIL mkdir -p /mnt/Shows
mkdir /mnt/Tank/Backup/Jailconfig/$JAIL
iocage fstab -a $JAIL /mnt/Tank/Backup/Jailconfig/$JAIL /config nullfs rw 0 0
iocage fstab -a $JAIL /mnt/Tank/Movies /mnt/Movies nullfs rw 0 0
iocage fstab -a $JAIL /mnt/Tank/Shows /mnt/Shows nullfs rw 0 0

# Creating multimedia group and add jellyfin user to group multimedia in jail
iocage exec $JAIL "pw groupadd multimedia -g 816"
iocage exec $JAIL "pw usermod jellyfin -G multimedia"

# Changing ownership to folders
iocage exec $JAIL chown -R jellyfin:multimedia /config
#iocage exec $JAIL chown -R jellyfin:multimedia /mnt/Movies
#iocage exec $JAIL chown -R jellyfin:multimedia /mnt/Shows

#iocage exec $JAIL nano /usr/local/etc/rc.d/jellyfin
#iocage exec $JAIL sysrc jellyfin_enable="YES"
#iocage exec $JAIL sysrc jellyfin_user=jellyfin
#iocage exec $JAIL sysrc jellyfin_group=multimedia
#iocage exec $JAIL sysrc jellyfin_data_dir="/config"
#iocage exec $JAIL sysrc jellyfin_exec_dir="/config"
#iocage exec $JAIL service jellyfin start
