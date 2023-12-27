#!/bin/bash
# Creating the jail for Bazarr. Change the name of the jail
JAIL="Bazarr"
iocage create -n $JAIL -r 13.2-RELEASE interfaces="vnet0:bridge0" defaultrouter="none" vnet="on" dhcp="on" bpf="yes" allow_raw_sockets="1" allow_mlock="1" boot="on"
iocage update $JAIL
iocage set enforce_statfs=1 $JAIL

# Updating the source to the latest repo
iocage exec $JAIL "mkdir -p /usr/local/etc/pkg/repos"
#iocage exec $JAIL "echo 'FreeBSD: {url: \"pkg+http://pkg.FreeBSD.org/\${ABI}/latest\"}' > /usr/local/etc/pkg/repos/FreeBSD.conf"
iocage exec $JAIL "echo 'FreeBSD: {url: \"pkg+http://pkg.FreeBSD.org/\${ABI}/quarterly\"}' > /usr/local/etc/pkg/repos/FreeBSD.conf"
iocage exec $JAIL pkg update

# Installing bazarr and dependencies - not found in freshports
iocage exec $JAIL pkg install -y bazarr nano
#iocage exec $JAIL pkg install -y git python39 unrar py39-webrtcvad py39-sqlite3 py39-pillow py39-numpy py39-lxml py39-pip

# Mounting storage and config
iocage exec $JAIL mkdir -p /config
iocage exec $JAIL mkdir -p /mnt/Movies
iocage exec $JAIL mkdir -p /mnt/Shows
mkdir /mnt/Tank/Backup/Jailconfig/$JAIL
#iocage exec $JAIL "cd /usr/local"
#iocage exec $JAIL "git clone https://github.com/morpheus65535/bazarr.git"
iocage fstab -a $JAIL /mnt/Tank/Backup/Jailconfig/$JAIL /config nullfs rw 0 0
iocage fstab -a $JAIL /mnt/Tank/Movies /mnt/Movies nullfs rw 0 0
iocage fstab -a $JAIL /mnt/Tank/Shows /mnt/Shows nullfs rw 0 0
#iocage exec $JAIL "cd bazarr"
#iocage exec $JAIL "pip install -r requirements.txt"
#iocage exec $JAIL "python3.9 bazarr.py"

# Creating multimedia group and add bazarr user to group multimedia in jail
iocage exec $JAIL "pw groupadd multimedia -g 816"
iocage exec $JAIL "pw usermod bazarr -G multimedia"

# Changing ownership to folders
iocage exec $JAIL chown -R bazarr:multimedia /config
#iocage exec $JAIL chown -R bazarr:multimedia /mnt/Movies
#iocage exec $JAIL chown -R bazarr:multimedia /mnt/Shows

#iocage exec $JAIL nano /usr/local/etc/rc.d/bazarr
iocage exec $JAIL sysrc "bazarr_enable=TRUE"
#iocage exec $JAIL sysrc bazarr_user=bazarr
iocage exec $JAIL sysrc bazarr_group=multimedia
iocage exec $JAIL sysrc bazarr_datadir="/config"
iocage exec $JAIL service bazarr start
