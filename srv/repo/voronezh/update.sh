#!/bin/bash
cd /srv/repo/voronezh/update/
rm -rf /srv/repo/voronezh/update/*
umount /mnt/iso -q
mount /srv/samba/public/99_Soft/Linux/repo/update/*.iso /mnt/iso/
cp -R /mnt/iso/* /srv/repo/voronezh/update/
umount /mnt/iso -q
