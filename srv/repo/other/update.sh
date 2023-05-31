#!/bin/bash
tar -xvf /usr/local/bin/install.tar.gz -C /usr/local/bin/
clear

#add repo for updates
#################################################################################################################
echo "deb ftp://dc1.uszson-chuna.lan/voronezh/main 1.7_x86-64 main contrib non-free" > /etc/apt/sources.list
echo "deb ftp://dc1.uszson-chuna.lan/voronezh/base 1.7_x86-64 main contrib non-free" >> /etc/apt/sources.list
echo "deb ftp://dc1.uszson-chuna.lan/voronezh/update 1.7_x86-64 main contrib non-free" >> /etc/apt/sources.list
#################################################################################################################

echo "Updating system, please wait..."
echo "Do not turn off your computer!"
sleep 5

apt update  &> install.log
sleep 5

apt -y dist-upgrade &>> install.log
sleep 5

#setup sync time from local server
######################################################
apt -y install chrony &>> install.log
sleep 5

mv /usr/local/bin/chrony.conf /etc/chrony/chrony.conf
sleep 5

######################################################

apt -y install libcupsimage2 &>> install.log
sleep 5

apt -y install lm-sensors &>> install.log
sleep 5

apt -y install rsync &>> install.log
sleep 5

apt -y install xrdp &>> install.log

apt -y install cifs-utils &>> install.log
sleep 5

apt -y install libpam-mount &>> install.log
sleep 5

apt -y install smartmontools &>> install.log
sleep 5


#add share mountpoint
####################################################################################

mkdir /mnt/share -v &>> install.log

mv /usr/local/bin/pam_mount.conf.xml  /etc/security/ -v &>> install.log 

####################################################################################

#read user and hostname from file
###################################################################################
while read a b c; do
    FILEUSER=$a
    FILEPASSWD=$b
    FILEPCNAME=$c
done < '/usr/local/bin/user'
###################################################################################


#add hostname
###################################################################################
hostnamectl set-hostname $FILEPCNAME
sleep 5
rm -f /etc/hosts

echo -e "
127.0.0.1       localhost
127.0.1.1       $FILEPCNAME.uszn-chuna.local $FILEPCNAME

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters

"> /etc/hosts
####################################################################################



#r7-office
###################################################################################
mkdir -p /etc/r7-office/license/ -v &>> install.log 
mv /usr/local/bin/license.lickey /etc/r7-office/license/license.lickey -v &>> install.log
chmod 777 /etc/r7-office/license/license.lickey -v &>> install.log
####################################################################################

#for kes
KESL_EULA_AGREED=Yes  
KESL_PRIVACY_POLICY_AGREED=Yes 

#install all debs in folder
####################################################################################
cd /usr/local/bin/
apt -y install ./*.deb --fix-broken &>> install.log
sleep 5
###################################################################################


#kes postinstall
#####################################################################################
/opt/kaspersky/kesl/bin/kesl-setup.pl --autoinstall=/usr/local/bin/kesl.ini &>> install.log
#####################################################################################


#one of 1 or 2
#1 create user
#####################################################################################
#adduser $FILEUSER --disabled-password --quiet --gecos ""
#usermod -aG video,users,plugdev,libvirt-qemu,libvirt,kvm,floppy,cdrom,dialout,audio,lpadmin $FILEUSER
#echo "$FILEUSER:$FILEPASSWD" | chpasswd
#chsh -s /bin/bash $FILESUER
#####################################################################################
#2 freeipa
#####################################################################################
#apt -y install fly-admin-freeipa-client &>> install.log
#sleep 5

#astra-freeipa-client -d uszson-chuna.lan -p temppassword -y &>> install.log
####################################################################################



apt -y install -f &>> install.log
sleep 5

apt -y autoremove &>> install.log
sleep 5


rm -f /etc/systemd/system/multi-user.target.wants/update.service
systemctl daemon-reload

#skeleton for new users
###################################################################################
rsync -va --delete-after /usr/local/bin/skel/ /etc/skel/ &>> install.log
###################################################################################

#clean
mv /usr/local/bin/install.log /home/

rm -Rf /usr/local/bin/*

####################################################################################

reboot
