#!/bin/bash
# Create the jail
iocage create -n "test112" -r 12.2-RELEASE interfaces="vnet0:bridge0" defaultrouter="none" vnet="on" dhcp="on" bpf="yes" allow_raw_sockets="1" allow_mlock="1" boot="on"
iocage update radarr

# Update to the latest repo
iocage exec radarr "mkdir -p /usr/local/etc/pkg/repos"
iocage exec radarr "echo 'FreeBSD: {url: \"pkg+http://pkg.FreeBSD.org/\${ABI}/latest\"}' > /usr/local/etc/pkg/repos/FreeBSD.conf"
iocage exec radarr pkg update

# Install dependencies
iocage exec radarr pkg install -y radarr

# Mount storage and config
iocage exec radarr mkdir -p /config
iocage fstab -a radarr /mnt/Vol1/jail_config_data/radarr /config nullfs rw 0 0
iocage fstab -a radarr /mnt/Vol1/media /media nullfs rw 0 0

# Create media user and group
iocage exec radarr "pw groupadd media -g 816"
iocage exec radarr "pw useradd -n media -u 1001 -d /nonexistent -s /usr/sbin/nologin"

iocage exec radarr chown -R media:media /config

#iocage exec radarr vi /usr/local/etc/rc.d/radarr
iocage exec radarr sysrc "radarr_enable=TRUE"
iocage exec radarr sysrc radarr_user=media
iocage exec radarr sysrc radarr_group=media
iocage exec radarr sysrc radarr_data_dir="/config"
iocage exec radarr service radarr start
