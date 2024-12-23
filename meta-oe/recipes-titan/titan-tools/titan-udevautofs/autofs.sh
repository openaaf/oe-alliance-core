#!/bin/sh
#

startconfig=/mnt/config/start-config
if [ ! -e "$startconfig" ]; then startconfig="/etc/titan.restore/mnt/config/start-config"; fi

. $startconfig
. /sbin/start-function

# (e)udev compatibility
[[ -z $MDEV ]] && MDEV=$(basename $DEVNAME)

if [ -e /etc/.debug ];then
	LOGDIR="/home/root/logs"
	[ ! -e "$LOGDIR" ] && mkdir -p "$LOGDIR"
	LOG="$LOGDIR/udev-autofs.$MDEV.log"
else
	LOG=/dev/null
fi

BLACKLISTED="mmcblk0"
FIRST_MEDIA="hdd"

## device information log
echo  >> $LOG
echo  >> $LOG
echo "**************************" >> $LOG
echo  >> $LOG
echo "Action= "$ACTION >> $LOG
echo "DEVNAME= "$DEVNAME >> $LOG
echo "Hotplug count ="$SEQNUM >> $LOG
echo "Major= "$MAJOR >> $LOG
echo "Mdev= "$MDEV >> $LOG
echo "Devpath= "$DEVPATH >> $LOG
echo "Devtype= "$DEVTYPE >> $LOG
echo "Subsystem= "$SUBSYSTEM >> $LOG
echo "Minor= "$MINOR >> $LOG
echo "Physdevpath= "$PHYSDEVPATH >> $LOG
echo "Physdevdriver= "$PHYSDEVDRIVER >> $LOG
echo "Physdevbus= "$PHYSDEVBUS >> $LOG
echo "Working directory= "$PWD >> $LOG
echo  >> $LOG
echo "*= "$* >> $LOG
echo "1= "$1 >> $LOG
echo "2= "$2 >> $LOG
echo "3= "$3 >> $LOG

echo ID_FS_TYPE: $ID_FS_TYPE >>$LOG
echo ID_FS_UUID_ENC: $ID_FS_UUID_ENC >>$LOG
echo ID_FS_UUID: $ID_FS_UUID >>$LOG
echo ID_SERIAL: $ID_SERIAL >>$LOG
echo ID_SERIAL_SHORT: $ID_SERIAL_SHORT >>$LOG
echo ID_USB_SERIAL: $ID_USB_SERIAL >>$LOG
echo ID_USB_SERIAL_SHORT: $ID_USB_SERIAL_SHORT >>$LOG
echo ID_FS_LABEL: $ID_FS_LABEL >>$LOG
echo ID_PART_ENTRY_UUID: $ID_PART_ENTRY_UUID >>$LOG
echo DM_NAME: $DM_NAME >>$LOG

getlabel()
{
	LABEL=${ID_FS_LABEL}
	if [ -z "$LABEL" ];then 
		LABEL=$(blkid -o value -s LABEL ${DEVNAME})
	fi

	case ${LABEL} in
		"")	if [ $(echo "${MDEV}" | grep "mmcblk0" | wc -l) -eq 1 ];then 
				LABEL="FLASH-${MDEV}"
			else
				LABEL="NONLABEL-${MDEV}"
			fi
			;;
		*)	case ${DEV} in
				"")	LABEL="${LABEL}-${MDEV}";;
				*)	LABEL="${LABEL}-${DEV}-(${MDEV})";;
			esac
			;;
	esac

#	case ${ACTION} in
#		"")	LABEL="${LABEL}";;
#		*)	LABEL="${LABEL}-(${ACTION})";;
#	esac
	echo $LABEL
}

#ACTION=add
case $ACTION in
	add)
		echo  >> $LOG
		echo "###################" >> $LOG
		echo "Action=$ACTION" >> $LOG
		echo  >> $LOG

		case $ID_FS_TYPE in
			crypto_LUKS)
				echo "ifup eth0" >> $LOG
				ifup eth0 >> $LOG 2>&1
				user=$(cat /proc/stb/info/boxtype)_$(ifconfig | sed 's/^$/#/g' | tr '\n' ' ' | tr '#' '\n' | grep inet | grep Bcast | awk '{print $7}' | cut -d":" -f2 | cut -d"." -f4)
				echo "user $user" >> $LOG
				[ -e /sys/class/net/eth0/address ] && pass=$(cat /sys/class/net/eth0/address | md5sum | awk '{ print $1 }')
				[ -e /proc/stb/info/sn ] && pass=$(cat /proc/stb/info/sn | md5sum | awk '{ print $1 }')
				echo "pass $pass" >> $LOG
				ip=$(route -n | grep -v 'default\|Destination\|Kernel' | awk '{ print $2}' | head -n1)
				echo ip $ip >> $LOG
				echo pwd
				pwd >> $LOG 2>&1
#				echo "wget ftp://$user:$pass@$ip/Dokumente/${ID_FS_UUID}" >> $LOG
				wget ftp://$user:$pass@$ip/Dokumente/crypt/${ID_FS_UUID} >> $LOG 2>&1
				echo "/usr/sbin/cryptsetup --key-file ${ID_FS_UUID} -S 2 luksOpen ${DEVNAME} ${MDEV}" >> $LOG
				/usr/sbin/cryptsetup -v --key-file ${ID_FS_UUID} -S 2 luksOpen ${DEVNAME} ${MDEV} >> $LOG 2>&1
				rm ${ID_FS_UUID}
				;;
			"")
				FSTYPE=${ID_FS_TYPE}
				[[ -z $FSTYPE ]] && FSTYPE=$(blkid -o value -s TYPE ${DEVNAME})
				echo "FSTYPE: ${FSTYPE} ID_FS_TYPE: ${ID_FS_TYPE} no filesystem found" >> $LOG
				;;
			*)
				LABEL=$( getlabel )
				echo "LABEL ${LABEL}" >> $LOG

				[ ! -e /media/usb ] && mkdir /media/usb
				FSTYPE=${ID_FS_TYPE}
				[[ -z $FSTYPE ]] && FSTYPE=$(blkid -o value -s TYPE ${DEVNAME})
				echo "FSTYPE ${FSTYPE}" >> $LOG
				case $autofsck in
					y)
		#				echo "/sbin/fsck.${FSTYPE} -f -p ${DEVNAME}" >> $LOG
		#				/sbin/fsck.${FSTYPE} -f -p ${DEVNAME} >> $LOG 2>&1
						echo "/sbin/fsck -C -f -p ${DEVNAME}" >> $LOG
						/sbin/fsck -C -f -p ${DEVNAME} >> $LOG 2>&1
				esac
				echo "/bin/ln -s /media/autofs/${MDEV} /media/usb/${LABEL}" >> $LOG
				/bin/ln -s /media/autofs/${MDEV} "/media/usb/${LABEL}" >> $LOG 2>&1

				echo "/bin/mkdir /media/${LABEL}" >> $LOG
				/bin/mkdir "/media/${LABEL}" >> $LOG 2>&1
				echo "/bin/mount ${DEVNAME} /media/${LABEL}" >> $LOG
				/bin/mount ${DEVNAME} "/media/${LABEL}" >> $LOG 2>&1

				[ -L /media/hdd ] && [ ! -e $(readlink /media/hdd) ] && rm /media/hdd && rm /media/.moviedev
				[ ! -e /media/hdd ] && [ -d "/media/${LABEL}/movie" ] && ln -s "/media/${LABEL}" /media/hdd && echo "$MDEV#$FSTYPE#$LABEL" > /media/.moviedev

				[ -L /var/backup ] && [ ! -e $(readlink /var/backup) ] && rm /var/backup && rm /media/.backupdev
				[ ! -e /var/backup ] && [ -d "/media/${LABEL}/backup" ] && ln -s "/media/${LABEL}/backup" /var/backup && echo "$MDEV#$FSTYPE#$LABEL" > /media/.backupdev

				[ -L /var/swapextensions ] && [ ! -e $(readlink /var/swapextensions) ] && rm /var/swapextensions && rm /media/.swapextensionsdev
				[ ! -e /var/swapextensions ] && [ -d "/media/${LABEL}/swapextensions" ] && ln -s "/media/${LABEL}/swapextensions" /var/swapextensions && echo "$MDEV#$FSTYPE#$LABEL" > /media/.swapextensionsdev
				;;
		esac
		;;
	change)
		echo  >> $LOG
		echo "###################" >> $LOG
		echo "Action=$ACTION" >> $LOG
		echo  >> $LOG
		DEV=$1
		LABEL=$( getlabel )
		echo "LABEL ${LABEL}" >> $LOG

		[ ! -e /media/usb ] && mkdir /media/usb
		FSTYPE=${ID_FS_TYPE}
		[[ -z $FSTYPE ]] && FSTYPE=$(blkid -o value -s TYPE ${DEVNAME})
		echo "FSTYPE ${FSTYPE}" >> $LOG
		case $autofsck in
			y)
#				echo "/sbin/fsck.${FSTYPE} -f -p ${DEVNAME}" >> $LOG
#				/sbin/fsck.${FSTYPE} -f -p ${DEVNAME} >> $LOG 2>&1
				echo "/sbin/fsck -C -f -p ${DEVNAME}" >> $LOG
				/sbin/fsck -C -f -p ${DEVNAME} >> $LOG 2>&1
		esac
		echo "/bin/ln -s /media/autofs/crypt-${DEV} /media/usb/${LABEL}" >> $LOG
		/bin/ln -s /media/autofs/crypt-${DEV} "/media/usb/${LABEL}" >> $LOG 2>&1

		echo "/bin/mkdir /media/${LABEL}" >> $LOG
		/bin/mkdir "/media/${LABEL}" >> $LOG 2>&1

		echo "/bin/mount /dev/mapper/${DEV} /media/${LABEL}" >> $LOG
		/bin/mount /dev/mapper/${DEV} "/media/${LABEL}" >> $LOG 2>&1

		[ -L /media/hdd ] && [ ! -e $(readlink /media/hdd) ] && rm /media/hdd && rm /media/.moviedev
		[ ! -e /media/hdd ] && [ -d "/media/${LABEL}/movie" ] && ln -s "/media/${LABEL}" /media/hdd && echo "$DEV#$FSTYPE#$LABEL" > /media/.moviedev

		[ -L /var/backup ] && [ ! -e $(readlink /var/backup) ] && rm /var/backup && rm /media/.backupdev
		[ ! -e /var/backup ] && [ -d "/media/${LABEL}/backup" ] && ln -s "/media/${LABEL}/backup" /var/backup && echo "$DEV#$FSTYPE#$LABEL" > /media/.backupdev

		[ -L /var/swapextensions ] && [ ! -e $(readlink /var/swapextensions) ] && rm /var/swapextensions && rm /media/.swapextensionsdev
		[ ! -e /var/swapextensions ] && [ -d "/media/${LABEL}/swapextensions" ] && ln -s "/media/${LABEL}/swapextensions" /var/swapextensions && echo "$DEV#$FSTYPE#$LABEL" > /media/.swapextensionsdev
		;;
	remove)
		echo  >> $LOG
		echo "###################" >> $LOG
		echo "Action=$ACTION" >> $LOG
		echo  >> $LOG
		echo "ID_FS_TYPE ${ID_FS_TYPE}" >> $LOG
		case $ID_FS_TYPE in
			crypto_LUKS)
				echo /bin/umount "/media/*-${MDEV}-*" >>$LOG
				/bin/umount "/media/*-${MDEV}-*" >>$LOG 2>&1

				echo /usr/sbin/cryptsetup close /dev/mapper/${MDEV} >>$LOG
				/usr/sbin/cryptsetup close /dev/mapper/${MDEV} >>$LOG 2>&1

				echo /bin/rmdir /media/*-${MDEV}-* >>$LOG
				/bin/rmdir /media/*-${MDEV}-* >>$LOG 2>&1

				echo /bin/rm /media/usb/*-${MDEV}-* >>$LOG
				/bin/rm /media/usb/*-${MDEV}-* >>$LOG 2>&1

				[ -L /media/hdd ] && [ ! -e $(readlink /media/hdd) ] && rm /media/hdd && rm /media/.moviedev
				[ -L /var/backup ] && [ ! -e $(readlink /var/backup) ] && rm /var/backup && rm /media/.backupdev
				[ -L /var/swapextensions ] && [ ! -e $(readlink /var/swapextensions) ] && rm /var/swapextensions && rm /media/.swapextensionsdev
				;;
			*)
				echo /bin/umount /media/*-${MDEV}-* >>$LOG
				/bin/umount /media/*-${MDEV}-* >>$LOG 2>&1

				echo /bin/rmdir /media/*-${MDEV}-* >>$LOG
				/bin/rmdir /media/*-${MDEV}-* >>$LOG 2>&1

				echo /bin/rm /media/usb/*-${MDEV}-* >>$LOG
				/bin/rm /media/usb/*-${MDEV}-* >>$LOG 2>&1

				[ -L /media/hdd ] && [ ! -e $(readlink /media/hdd) ] && rm /media/hdd && rm /media/.moviedev
				[ -L /var/backup ] && [ ! -e $(readlink /var/backup) ] && rm /var/backup && rm /media/.backupdev
				[ -L /var/swapextensions ] && [ ! -e $(readlink /var/swapextensions) ] && rm /var/swapextensions && rm /media/.swapextensionsdev
				;;
		esac
		;;
esac

