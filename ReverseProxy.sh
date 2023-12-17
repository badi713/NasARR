#!/bin/bash
# Creating the jail for Reverse proxy. Change the name of the jail
JAIL="Reversep"
iocage create -n $JAIL -r 13.2-RELEASE interfaces="vnet0:bridge0" defaultrouter="none" vnet="on" dhcp="on" bpf="yes" allow_raw_sockets="1" allow_mlock="1" boot="on"
iocage update $JAIL

# Updating the source to the latest repo
iocage exec $JAIL "mkdir -p /usr/local/etc/pkg/repos"
iocage exec $JAIL "echo 'FreeBSD: {url: \"pkg+http://pkg.FreeBSD.org/\${ABI}/latest\"}' > /usr/local/etc/pkg/repos/FreeBSD.conf"
iocage exec $JAIL pkg update

# Installing nginx and dependencies
iocage exec $JAIL pkg install -y nginx

# Mounting storage and config
iocage exec $JAIL mkdir -p /config
mkdir /mnt/Tank/Backup/Jailconfig/$JAIL
iocage fstab -a $JAIL /mnt/Tank/Backup/Jailconfig/$JAIL /config nullfs rw 0 0


# Changing ownership to folders
iocage exec $JAIL chown -R badi713:multimedia /config


#iocage exec radarr vi /usr/local/etc/rc.d/radarr
#iocage exec $JAIL sysrc "radarr_enable=TRUE"
#iocage exec $JAIL sysrc radarr_user=radarr
#iocage exec $JAIL sysrc radarr_group=multimedia
#iocage exec $JAIL sysrc radarr_data_dir="/config"
#iocage exec $JAIL service radarr start