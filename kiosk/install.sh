#!/bin/bash

apt-get update

apt-get upgrade

apt install -y xorg openbox numlockx

wget https://github.com/deemru/Chromium-Gost/releases/download/111.0.5563.147/chromium-gost-111.0.5563.147-linux-amd64.deb

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
if [ -z "\$DISPLAY" ] && [ \$(tty) = /dev/tty1 ]; then
. startx
logout
fi
EOF

cat > /home/kiosk/.config/chromium-gost.sh <<EOF
#!/bin/bash

while true
 do
if [ $(pgrep chrome -c) != "0" ]
then
sleep 5
else
/usr/bin/chromium-gost --disable-infobars --incognito --no-first-run --disable --disable-translate --disable-infobars --disable-suggestions-service --disable-save-password-bubble\
--noerrdialogs --no-first-run --fast --fast-start --disable-infobars --disable-features=TranslateUI --disk-cache-dir=/dev/null --password-store=basic --disable-pinch\
--overscroll-history-navigation=disabled --disable-features=TouchpadOverscrollHistoryNavigation    'https://www.gosuslugi.ru'  'https://account.mail.ru' 'https://gmail.com'
rm -Rf *
sleep 5
fi
done
EOF

chmod +x /home/kiosk/.config/chromium-gost.sh

cat >> /etc/xdg/openbox/autostart <<EOF
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
    "URLAllowlist": ["gosuslugi.ru", "account.mail.ru","auth.mail.ru","e.mail.ru", "mail.yandex.ru","360.yandex.ru","passport.yandex.ru","gmail.com","mail.google.com","accounts.google.com","accounts.google.ru"]
}
EOF

cat >> /etc/chromium/policies/managed/ForcedLanguages.json <<EOF
{
  "ForcedLanguages": ["ru-RU"]
}
EOF

update-grub

rm *.deb

rm install.sh

reboot
