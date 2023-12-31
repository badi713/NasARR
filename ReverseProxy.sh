#!/bin/bash
# Creating the jail for Reverse proxy. Change the name of the jail
JAIL="Reversep"
iocage destroy $JAIL -f
iocage create -n $JAIL -r 13.2-RELEASE interfaces="vnet0:bridge0" defaultrouter="none" vnet="on" dhcp="on" bpf="yes" allow_raw_sockets="1" allow_mlock="1" boot="on"
iocage update $JAIL


# Updating the source to the latest repo
iocage exec $JAIL "mkdir -p /usr/local/etc/pkg/repos"
iocage exec $JAIL "echo 'FreeBSD: {url: \"pkg+http://pkg.FreeBSD.org/\${ABI}/latest\"}' > /usr/local/etc/pkg/repos/FreeBSD.conf"
iocage exec $JAIL pkg update

# Installing nginx and dependencies
iocage exec $JAIL pkg install -y nginx security/py-certbot-nginx

# Mounting storage and config
#iocage exec $JAIL mkdir -p /usr/local/etc/nginx
mkdir /mnt/Tank/Backup/Jailconfig/$JAIL
iocage fstab -a $JAIL /mnt/Tank/Backup/Jailconfig/$JAIL /usr/local/etc/nginx nullfs rw 0 0

# Creating multimedia group and add www user to group multimedia in jail
iocage exec $JAIL "pw groupadd multimedia -g 816"
iocage exec $JAIL "pw usermod www -G multimedia"

# Changing ownership to folders
wget https://github.com/badi713/NasARR/raw/main/nginx.conf -O /usr/local/etc/nginx/nginx.conf --backups=0
iocage exec $JAIL chown -R www:multimedia /usr/local/etc/nginx

# Requesting new certificate from LetsEncrypt in standalone mode.
# Be sure that the jail is accesible from outside
iocage exec $JAIL certbot certonly --standalone

#iocage exec $JAIL vi /usr/local/etc/rc.d/nginx
iocage exec $JAIL sysrc nginx_enable="YES"
iocage exec $JAIL service nginx start
