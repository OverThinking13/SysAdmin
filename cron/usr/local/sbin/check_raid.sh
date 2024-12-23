#!/bin/bash

if [[ $(/usr/sbin/mdadm --detail /dev/md* | grep degraded | wc -l) -eq 1 ]]; then
        /usr/sbin/mdadm --detail /dev/md* | /usr/bin/mutt -s "Чунский филиал не спать! Ошибка на сервере!" ****@mail.ru
fi
