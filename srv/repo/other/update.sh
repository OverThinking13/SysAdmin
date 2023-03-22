#!/bin/bash
tar -xvf /usr/local/bin/install.tar.gz -C /usr/local/bin/
clear

echo "deb ftp://dc1.uszn-chuna.local/voronezh/main 1.7_x86-64 main contrib non-free" > /etc/apt/sources.list
echo "deb ftp://dc1.uszn-chuna.local/voronezh/base 1.7_x86-64 main contrib non-free" >> /etc/apt/sources.list
echo "deb ftp://dc1.uszn-chuna.local/voronezh/update 1.7_x86-64 main contrib non-free" >> /etc/apt/sources.list


echo "Updating system, please wait..."
echo "Do not turn off your computer!"
sleep 5
apt update  &> install.log
sleep 5

apt -y dist-upgrade &>> install.log
sleep 5

apt -y install chrony &>> install.log
sleep 5

apt -y install libcupsimage2 &>> install.log
sleep 5

apt -y install lm-sensors &>> install.log
sleep 5

#apt -y install amd64-microcode &>> install.log
sleep 5

apt -y install xrdp &>> install.log
mv /usr/local/bin/chrony.conf /etc/chrony/chrony.conf
sleep 5

apt -y install cifs-utils &>> install.log
sleep 5

apt -y install libpam-mount &>> install.log
sleep 5

apt -y install smartmontools &>> install.log
sleep 5


mkdir -p /etc/r7-office/license/ -v &>> install.log
mv /usr/local/bin/license.lickey /etc/r7-office/license/license.lickey -v &>> install.log
chmod 777 /etc/r7-office/license/license.lickey -v &>> install.log

KESL_EULA_AGREED=Yes
KESL_PRIVACY_POLICY_AGREED=Yes


cd /usr/local/bin/
apt -y install ./*.deb --fix-broken &>> install.log
sleep 5


#####################################################################################
while read a b c; do
    FILEUSER=$a
    FILEPASSWD=$b
    FILEPCNAME=$c
done < '/usr/local/bin/user'

useradd -m $FILEUSER
usermod -aG video,users,plugdev,libvirt-qemu,libvirt,kvm,floppy,cdrom,dialout,audio,lpadmin $FILEUSER
echo "$FILEUSER:$FILEPASSWD" | chpasswd

hostnamectl set-hostname $FILEPCNAME
sleep 5

mkdir -p /home/$FILEUSER/ -v &>> install.log

chsh -s /bin/bash $FILESUER
####################################################################################

mkdir /mnt/share -v &>> install.log

mv pam_mount.conf.xml  /etc/security/ -v &>> install.log

####################################################################################
rm -f /etc/hosts
####################################################################################
echo -e "
127.0.0.1       localhost
127.0.1.1       $FILEPCNAME.uszn-chuna.local $FILEPCNAME

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters

"> /etc/hosts
####################################################################################


/opt/kaspersky/kesl/bin/kesl-setup.pl --autoinstall=/usr/local/bin/kesl.ini &>> install.log


apt -y install -f &>> install.log
sleep 5

apt -y autoremove &>> install.log
sleep 5


rm -f /etc/systemd/system/multi-user.target.wants/update.service
systemctl daemon-reload

mv install.log /home/$FILEUSER/ -v &>> install.log
rm -f /usr/local/bin/*
mv /usr/local/bin/{.*,*} /home/$FILEUSER/ -v &>> install.log

####################################################################################
chown -R $FILEUSER:$FILEUSER /home/$FILEUSER -v &>> /home/$FILEUSER/install.log
####################################################################################

reboot
