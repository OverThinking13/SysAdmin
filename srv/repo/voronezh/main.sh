#!/bin/bash
cd /srv/repo/voronezh/main/
rm -rf /srv/repo/voronezh/main/*
umount /mnt/iso -q
mount /srv/samba/public/99_Soft/Linux/repo/main/1.7*.iso /mnt/iso/
cp -R /mnt/iso/* /srv/repo/voronezh/main/
umount /mnt/iso -q
