#!/bin/bash

apt-get update

apt-get upgrade

apt install -y xorg openbox numlockx

wget https://github.com/deemru/Chromium-Gost/releases/download/131.0.6778.108/chromium-gost-131.0.6778.108-linux-amd64.deb

apt install -f -y ./*.deb

useradd -m -g users kiosk

sed 's/<!-- Keybindings for desktop switching -->/\
<!-- Keybindings for desktop switching -->\
<keybind key="F12">\
      <action name="Execute">\
        <command>\/sbin\/shutdown -h now<\/command>\
      <\/action>\
    <\/keybind>\
/' /etc/xdg/openbox/rc.xml > rc.xml

mkdir -p /home/kiosk/.config/openbox/
mv rc.xml /home/kiosk/.config/openbox/rc.xml
chown -R kiosk:users /home/kiosk/{*,.*}

mkdir -p /etc/systemd/system/getty@tty1.service.d/

cat > /etc/systemd/system/getty@tty1.service.d/autologin.conf << EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty -a kiosk --noclear %I $TERM
EOF

cat >> /home/kiosk/.profile <<EOF
LANGUAGE=ru_RU:ru
LANG=ru_RU.UTF-8
if [ -z "\$DISPLAY" ] && [ \$(tty) = /dev/tty1 ]; then
. startx
logout
fi
EOF

cat > /home/kiosk/.config/chromium-gost.sh <<EOF
#!/bin/bash

while true
 do
if [ 0 != "0" ]
then
sleep 5
else
/usr/bin/chromium-gost --disable-infobars --incognito --start-maximized --no-first-run --disable-translate --disable-infobars \
--disable-suggestions-service --disable-save-password-bubble --noerrdialogs --fast-start --disable-features=TranslateUI \
--disk-cache-dir=/dev/null --password-store=basic --disable-pinch--overscroll-history-navigation=disabled \
--disable-features=TouchpadOverscrollHistoryNavigation --lang=ru_RU --accept-lang=ru_RU,en_US\
'https://www.gosuslugi.ru' 'https://trudvsem.ru' 'https://account.mail.ru' 'https://gmail.com' \
'https://forms.yandex.ru/u/671f456673cee711b69a14d4' 'https://new.profczn.ru/167679?id=2242337' 'https://new.profczn.ru/167682?id=2242337'
rm -Rf *
sleep 5
fi
done
EOF

chmod +x /home/kiosk/.config/chromium-gost.sh

cat >> /etc/xdg/openbox/autostart <<EOF
sleep 10
xset -dpms &
xset s off &
xset s noblank &
numlockx on &
setxkbmap -layout "us,ru" -option "grp:alt_shift_toggle" &
.config/chromium-gost.sh &
EOF

sudo chmod u+s /sbin/shutdown

sed  's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/' /etc/default/grub > grub
mv grub /etc/default/grub

mkdir -p /etc/chromium/policies/managed
mkdir /etc/chromium/policies/recommended

cat >> /etc/chromium/policies/managed/URLBlocklist.json <<EOF
{
  "URLBlocklist": ["*"]
}
EOF

cat >> /etc/chromium/policies/managed/URLAllowlist.json <<EOF
{
    "URLAllowlist": [
"gosuslugi.ru",
"mail.ru",
"yandex.ru",
"gmail.com",
"google.com",
"google.ru",
"profczn.ru",
"trudvsem.ru",
"print"
]
}
EOF

cat >> /etc/chromium/policies/managed/ForcedLanguages.json <<EOF
{
  "ForcedLanguages": ["ru-RU"]
}
EOF

apt install wireplumber pipewire-media-session-


update-grub

rm *.deb

rm install.sh

reboot
