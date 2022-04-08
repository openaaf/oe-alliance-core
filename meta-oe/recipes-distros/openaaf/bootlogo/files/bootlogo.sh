# avoid the console messages clobbering our logo
[ -f /sys/class/vtconsole/vtcon1/bind ] && echo 0 > /sys/class/vtconsole/vtcon1/bind
# and set the correct videomode before showing the bootlogo
[ -f /etc/videomode ] && cat /etc/videomode > /proc/stb/video/videomode

BOOTLOGO=/usr/share/bootlogo.mvi
[ -f /etc/enigma2/bootlogo.mvi ] && BOOTLOGO=/etc/enigma2/bootlogo.mvi
/usr/bin/showiframe ${BOOTLOGO}

[ -f /etc/init.d/bootlogo.py ] && /usr/bin/python /etc/init.d/bootlogo.py

startconfig=/mnt/config/start-config
if [ ! -e "$startconfig" ]; then startconfig="/etc/titan.restore/mnt/config/start-config"; fi
. $startconfig
if [ "$bootlogo" == 'y' ]; then
    if [ -e /mnt/swapextensions/etc/boot/bootlogo.jpg ]; then
	    infobox 200 "nobox#/mnt/swapextensions/etc/boot/bootlogo.jpg" &
    else
	    if [ -e /var/etc/boot/bootlogo.jpg ]; then
		    infobox 200 "nobox#/var/etc/boot/bootlogo.jpg" &
	    fi
    fi
fi
