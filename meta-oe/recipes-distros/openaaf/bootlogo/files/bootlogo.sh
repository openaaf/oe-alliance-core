# avoid the console messages clobbering our logo
[ -f /sys/class/vtconsole/vtcon1/bind ] && echo 0 > /sys/class/vtconsole/vtcon1/bind
# and set the correct videomode before showing the bootlogo
[ -f /etc/videomode ] && cat /etc/videomode > /proc/stb/video/videomode

BOOTLOGO=/usr/share/bootlogo.mvi
[ -f /etc/enigma2/bootlogo.mvi ] && BOOTLOGO=/etc/enigma2/bootlogo.mvi
/usr/bin/showiframe ${BOOTLOGO}

[ -f /etc/init.d/bootlogo.py ] && /usr/bin/python /etc/init.d/bootlogo.py

startconfig=/mnt/config/start-config
[ ! -e "$startconfig" ] && startconfig=/etc/titan.restore/mnt/config/start-config
. $startconfig

BOOTLOGO=/var/etc/boot/bootlogo.jpg
[ -f /mnt/swapextensions/etc/boot/bootlogo.jpg ] && BOOTLOGO=/mnt/swapextensions/etc/boot/bootlogo.jpg
[ "$bootlogo" == 'y' ] && infobox 200 "nobox#${BOOTLOGO}" &
