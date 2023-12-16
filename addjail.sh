#!/bin/bash
# Create the jail
JAIL="test112"
iocage create -n $JAIL -r 12.4-RELEASE interfaces="vnet0:bridge0" defaultrouter="none" vnet="on" dhcp="on" bpf="yes" allow_raw_sockets="1" allow_mlock="1" boot="on"
iocage update $JAIL

# Update to the latest repo
iocage exec $JAIL "mkdir -p /usr/local/etc/pkg/repos"
iocage exec $JAIL "echo 'FreeBSD: {url: \"pkg+http://pkg.FreeBSD.org/\${ABI}/latest\"}' > /usr/local/etc/pkg/repos/FreeBSD.conf"
iocage exec $JAIL pkg update

# Install dependencies
iocage exec $JAIL pkg install -y radarr

# Mount storage and config
iocage exec $JAIL mkdir -p /config
#iocage fstab -a $JAIL /mnt/Vol1/jail_config_data/radarr /config nullfs rw 0 0
#iocage fstab -a $JAIL /mnt/Vol1/media /media nullfs rw 0 0

# Create media user and group
iocage exec $JAIL "pw groupadd media -g 816"
iocage exec $JAIL "pw useradd -n media -u 1001 -d /nonexistent -s /usr/sbin/nologin"

iocage exec $JAIL chown -R media:media /config

#iocage exec radarr vi /usr/local/etc/rc.d/radarr
iocage exec $JAIL sysrc "radarr_enable=TRUE"
iocage exec $JAIL sysrc radarr_user=media
iocage exec $JAIL sysrc radarr_group=media
iocage exec $JAIL sysrc radarr_data_dir="/config"
iocage exec $JAIL service radarr start
