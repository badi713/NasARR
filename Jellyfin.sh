#!/bin/bash
# Creating the jail for Jellyfin. Change the name of the jail
echo "Creating the jail for Jellyfin. Change the name of the jail"
JAIL="Jellyfin"
iocage destroy $JAIL -f
iocage create -n $JAIL -r 13.2-RELEASE interfaces="vnet0:bridge0" defaultrouter="none" vnet="on" dhcp="on" bpf="yes" allow_raw_sockets="1" allow_mlock="1" boot="on"
iocage update $JAIL
iocage set enforce_statfs=1 $JAIL

# Updating the source to the latest repo
echo "Updating the source to the latest repo"
iocage exec $JAIL "mkdir -p /usr/local/etc/pkg/repos"
iocage exec $JAIL "echo 'FreeBSD: {url: \"pkg+http://pkg.FreeBSD.org/\${ABI}/latest\"}' > /usr/local/etc/pkg/repos/FreeBSD.conf"
#iocage exec $JAIL "echo 'FreeBSD: {url: \"pkg+http://pkg.FreeBSD.org/\${ABI}/quarterly\"}' > /usr/local/etc/pkg/repos/FreeBSD.conf"
iocage exec $JAIL pkg update

# Mounting config
echo "Mounting config"
#mkdir /mnt/Tank/Backup/Jailconfig/$JAIL/db
#mkdir /mnt/Tank/Backup/Jailconfig/$JAIL/web
#iocage exec $JAIL mkdir -p /var/db/jellyfin
#iocage exec $JAIL mkdir -p /usr/local/jellyfin
#iocage fstab -a $JAIL /mnt/Tank/Backup/Jailconfig/$JAIL/db /var/db/jellyfin nullfs rw 0 0
#iocage fstab -a $JAIL /mnt/Tank/Backup/Jailconfig/$JAIL/web /usr/local/jellyfin nullfs rw 0 0

# Installing jellyfin and dependencies
echo "Installing jellyfin and dependencies"
iocage exec $JAIL pkg install -y jellyfin nano

# Mounting storage
echo "Mounting storage"
iocage exec $JAIL mkdir -p /mnt/Movies
iocage exec $JAIL mkdir -p /mnt/Shows
iocage fstab -a $JAIL /mnt/Tank/Movies /mnt/Movies nullfs rw 0 0
iocage fstab -a $JAIL /mnt/Tank/Shows /mnt/Shows nullfs rw 0 0

# Creating multimedia group and add jellyfin user to group multimedia in jail
echo "Creating multimedia group and add jellyfin user to group multimedia in jail"
iocage exec $JAIL "pw groupadd multimedia -g 816"
iocage exec $JAIL "pw usermod jellyfin -G multimedia"

# Changing ownership to folders
echo "Changing ownership to folders"
iocage exec $JAIL chown -R jellyfin:multimedia /var/db/jellyfin
iocage exec $JAIL chown -R jellyfin:multimedia /usr/local/jellyfin
#iocage exec $JAIL chown -R jellyfin:multimedia /mnt/Movies
#iocage exec $JAIL chown -R jellyfin:multimedia /mnt/Shows

# Enable service and run
echo "Enable service and run"
#iocage exec $JAIL nano /usr/local/etc/rc.d/jellyfin
#iocage exec $JAIL sysrc jellyfin_enable="YES"
iocage exec $JAIL service jellyfin enable
#iocage exec $JAIL sysrc jellyfin_user=jellyfin
iocage exec $JAIL sysrc jellyfin_group=multimedia
iocage exec $JAIL sysrc JELLYFIN_DATA_DIR=/var/db/jellyfin/data
iocage exec $JAIL sysrc JELLYFIN_CONFIG_DIR=/var/db/jellyfin/config
iocage exec $JAIL sysrc JELLYFIN_LOG_DIR=/var/db/jellyfin/log
iocage exec $JAIL sysrc JELLYFIN_CACHE_DIR=/var/db/jellyfin/cache
iocage exec $JAIL service jellyfin start
