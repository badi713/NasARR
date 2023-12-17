#!/bin/bash
# Creating the jail for Bazarr. Change the name of the jail
JAIL="Bazarr"
iocage create -n $JAIL -r 13.2-RELEASE interfaces="vnet0:bridge0" defaultrouter="none" vnet="on" dhcp="on" bpf="yes" allow_raw_sockets="1" allow_mlock="1" boot="on"
#iocage update $JAIL
iocage set enforce_statfs=1 $JAIL

# Updating the source to the latest repo
iocage exec $JAIL "mkdir -p /usr/local/etc/pkg/repos"
iocage exec $JAIL "echo 'FreeBSD: {url: \"pkg+http://pkg.FreeBSD.org/\${ABI}/latest\"}' > /usr/local/etc/pkg/repos/FreeBSD.conf"
#iocage exec $JAIL pkg update

# Installing bazarr and dependencies
iocage exec $JAIL pkg install -y bazarr

# Mounting storage and config
iocage exec $JAIL mkdir -p /config
iocage exec $JAIL mkdir -p /mnt/Movies
iocage exec $JAIL mkdir -p /mnt/Shows
mkdir /mnt/Tank/Backup/Jailconfig/$JAIL
iocage fstab -a $JAIL /mnt/Tank/Backup/Jailconfig/$JAIL /config nullfs rw 0 0
iocage fstab -a $JAIL /mnt/Tank/Movies /mnt/Movies nullfs rw 0 0
iocage fstab -a $JAIL /mnt/Tank/Shows /mnt/Shows nullfs rw 0 0

# Creating multimedia group and add bazarr user to group multimedia in jail
iocage exec $JAIL "pw groupadd multimedia -g 816"
iocage exec $JAIL "pw usermod bazarr -G multimedia"

# Changing ownership to folders
iocage exec $JAIL chown -R bazarr:multimedia /config
#iocage exec $JAIL chown -R bazarr:multimedia /mnt/Movies
#iocage exec $JAIL chown -R bazarr:multimedia /mnt/Shows

#iocage exec bazarr vi /usr/local/etc/rc.d/bazarr
iocage exec $JAIL sysrc "bazarr_enable=TRUE"
#iocage exec $JAIL sysrc bazarr_user=bazarr
iocage exec $JAIL sysrc bazarr_group=multimedia
iocage exec $JAIL sysrc bazarr_data_dir="/config"
iocage exec $JAIL service bazarr start
