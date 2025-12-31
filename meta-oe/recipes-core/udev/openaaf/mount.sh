#!/bin/sh
#

startconfig=/mnt/config/start-config
if [ ! -e "$startconfig" ]; then startconfig="/etc/titan.restore/mnt/config/start-config"; fi

titanconfig=/mnt/config/titan.cfg
if [ ! -e "$titanconfig" ]; then titanconfig="/etc/titan.restore/mnt/config/titan.cfg"; fi

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

[ -e /var/swap ] && [ -d /var/swap ] && rm -rf /var/swap && echo remove /var/swap folder >> $LOG

BLACKLISTED="mmcblk0"
FIRST_MEDIA="hdd"
EXTRA=""

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
				case ${DM_NAME} in
					"")	LABEL="NONLABEL-${MDEV}";;
					*)	LABEL="NONLABEL-${DM_NAME}-(${MDEV})";;
				esac
			fi
			;;
		*)	case ${DM_NAME} in
				"")	LABEL="${LABEL}-${MDEV}";;
				*)	LABEL="${LABEL}-${DM_NAME}-(${MDEV})";;
			esac
			;;
	esac
	echo $LABEL
}


usescript()
{
	MDEV=${1}
	AUTOFS=${2}
	DEVNAME=${3}
	FSTYPE=${4}
	LABEL=${5}
	EXTRA=${6}

	SCRIPTDIR="/media/.script"
	[ ! -e "$SCRIPTDIR" ] && mkdir -p "$SCRIPTDIR"
	SCRIPT=/media/.script/${MDEV}

	echo "#!/bin/sh" > $SCRIPT
	echo "#" >> $SCRIPT
	echo "" >> $SCRIPT
	echo "case $autofsck in" >> $SCRIPT
	echo "	y)" >> $SCRIPT
	echo "		case ${FSTYPE} in" >> $SCRIPT
	echo "			\"ntfs\")	echo Found NTFS skip filesystem check;;" >> $SCRIPT
	echo "			*)" >> $SCRIPT
	echo "				touch /media/.running.fsck.${MDEV}" >> $SCRIPT
	echo "#				echo \"/sbin/fsck.${FSTYPE} -f -p ${DEVNAME}\" >> $LOG" >> $SCRIPT
	echo "#				/sbin/fsck.${FSTYPE} -f -p ${DEVNAME} >> $LOG 2>&1" >> $SCRIPT
	echo "				echo \"/sbin/fsck -C -f -p ${DEVNAME}\" >> $LOG" >> $SCRIPT
	echo "				/sbin/fsck -C -f -p ${DEVNAME} >> $LOG 2>&1" >> $SCRIPT
	echo "				rm /media/.running.fsck.${MDEV}" >> $SCRIPT
	echo "		esac" >> $SCRIPT
	echo "esac" >> $SCRIPT
	echo "[ -L \"/media/usb/${LABEL}\" ] && echo \"skip: ${LABEL} found link\" >> $LOG && exit 1" >> $SCRIPT
	echo "echo \"/bin/ln -s /media/autofs/${AUTOFS} /media/usb/${LABEL}\" >> $LOG" >> $SCRIPT
	echo "/bin/ln -s /media/autofs/${AUTOFS} \"/media/usb/${LABEL}\" >> $LOG 2>&1" >> $SCRIPT
	echo "" >> $SCRIPT
	echo "[ -e \"/media/${LABEL}\" ] && echo \"skip: ${LABEL} found folder\" >> $LOG && exit 1" >> $SCRIPT
	echo "echo \"/bin/mkdir /media/${LABEL}\" >> $LOG" >> $SCRIPT
	echo "/bin/mkdir \"/media/${LABEL}\" >> $LOG 2>&1" >> $SCRIPT
	echo "" >> $SCRIPT
	echo "mountpoint -q \"/media/${LABEL}\" && echo \"skip: ${LABEL} is already mounted\" >> $LOG && exit 1" >> $SCRIPT
	echo "echo \"/bin/mount ${DEVNAME} /media/${LABEL}\" >> $LOG" >> $SCRIPT
	echo "/bin/mount ${DEVNAME} \"/media/${LABEL}\" >> $LOG 2>&1" >> $SCRIPT
	echo "" >> $SCRIPT
#	echo "sleeptime=$(echo \"$(cat $titanconfig | grep timetosleep= | cut -d\= -f2) / 6 * 1.2\" | bc | cut -d\. -f1)" >> $SCRIPT
#	echo "echo \"/sbin/hdparm -S $sleeptime -B 127 /dev/${MDEV}\" >> $LOG" >> $SCRIPT
#	echo "/sbin/hdparm -S $sleeptime -B 127 /dev/${MDEV} >> $LOG 2>&1" >> $SCRIPT
	echo "" >> $SCRIPT
	echo "[ -L /media/hdd ] && [ ! -e $(readlink /media/hdd) ] && rm /media/hdd && rm /media/.moviedev" >> $SCRIPT
	echo "[ ! -e /media/hdd ] && [ -d \"/media/${LABEL}/movie\" ] && ln -s \"/media/${LABEL}\" /media/hdd && echo \"$MDEV#$FSTYPE#$LABEL\" > /media/.moviedev" >> $SCRIPT
	echo "" >> $SCRIPT
	echo "[ -L /var/backup ] && [ ! -e $(readlink /var/backup) ] && rm /var/backup && rm /media/.backupdev" >> $SCRIPT
	echo "[ ! -e /var/backup ] && [ -d \"/media/${LABEL}/backup\" ] && ln -s \"/media/${LABEL}/backup\" /var/backup && echo \"$MDEV#$FSTYPE#$LABEL\" > /media/.backupdev" >> $SCRIPT
	echo "" >> $SCRIPT
	echo "[ -L /var/swap ] && [ ! -e $(readlink /var/swap) ] && rm /var/swap && rm /media/.swapextensionsdev" >> $SCRIPT
	echo "[ ! -e /var/swap ] && [ -d \"/media/${LABEL}/swapextensions\" ] && ln -s \"/media/${LABEL}/swapextensions\" /var/swap && echo \"$MDEV#$FSTYPE#$LABEL\" > /media/.swapextensionsdev" >> $SCRIPT

	chmod 755 $SCRIPT
	if [ -z ${EXTRA} ];then
		$SCRIPT ${EXTRA}
	else
		$SCRIPT &
	fi
}

usecommand()
{
	MDEV=${1}
	AUTOFS=${2}
	DEVNAME=${3}
	FSTYPE=${4}
	LABEL=${5}
	EXTRA=${6}

	if [ -e "/media/.running.fsck.${DEVNAME}" ];then
		echo "skip: ${LABEL} fsck is running" >> $LOG
	else
		case $autofsck in
			y)
				case ${FSTYPE} in
					"ntfs") echo "Found NTFS skip filesystem check" >> $LOG;;
					*)
	#					echo "/sbin/fsck.${FSTYPE} -f -p ${DEVNAME}" >> $LOG
	#					/sbin/fsck.${FSTYPE} -f -p ${DEVNAME} >> $LOG 2>&1
						touch /media/.running.fsck.${MDEV}
						echo "/sbin/fsck -C -f -p ${DEVNAME}" >> $LOG
						/sbin/fsck -C -f -p ${DEVNAME} >> $LOG 2>&1
						rm /media/.running.fsck.${MDEV}
				esac
		esac
	fi

#	[ -L "/media/usb/${LABEL}" ] && echo "skip: ${LABEL} found link" >> $LOG && exit 1
	if [ -L "/media/usb/${LABEL}" ];then
		echo "skip: ${LABEL} found link" >> $LOG
	else
		echo /bin/ln -s /media/autofs/${AUTOFS} /media/usb/${LABEL} >> $LOG
		/bin/ln -s /media/autofs/${AUTOFS} "/media/usb/${LABEL}" >> $LOG 2>&1
	fi

#	[ -e "/media/${LABEL}" ] && echo "skip: ${LABEL} found folder" >> $LOG && exit 1
	if [ -e "/media/${LABEL}" ];then
		echo "skip: ${LABEL} found folder" >> $LOG
	else
		echo /bin/mkdir /media/${LABEL} >> $LOG
		/bin/mkdir "/media/${LABEL}" >> $LOG 2>&1
	fi

	mountpoint -q "/media/${LABEL}" && echo "skip: ${LABEL} is already mounted" >> $LOG && exit 1
	echo /bin/mount ${DEVNAME} /media/${LABEL} >> $LOG
	/bin/mount ${DEVNAME} "/media/${LABEL}" >> $LOG 2>&1


	sleeptime=$(echo "$(cat $titanconfig | grep timetosleep= | cut -d\= -f2) / 6 * 1.2" | bc | cut -d\. -f1)
	echo /sbin/hdparm -S $sleeptime -B 127 /dev/${MDEV} >> $LOG
	/sbin/hdparm -S $sleeptime -B 127 /dev/${MDEV} >> $LOG 2>&1

#/sbin/hdparm -S 60 -B 127 /dev/sdf1
# HDIO_DRIVE_CMD failed: Input/output error
#
#/dev/sdf1:
# setting Advanced Power Management level to 0x7f (127)
# setting standby to 120 (10 minutes)
# APM_level	= not supported

	[ -L /media/hdd ] && [ ! -e $(readlink /media/hdd) ] && rm /media/hdd && rm /media/.moviedev
	[ ! -e /media/hdd ] && [ -d "/media/${LABEL}/movie" ] && ln -s "/media/${LABEL}" /media/hdd && echo "$MDEV#$FSTYPE#$LABEL" > /media/.moviedev

	[ -L /var/backup ] && [ ! -e $(readlink /var/backup) ] && rm /var/backup && rm /media/.backupdev
	[ ! -e /var/backup ] && [ -d "/media/${LABEL}/backup" ] && ln -s "/media/${LABEL}/backup" /var/backup && echo "$MDEV#$FSTYPE#$LABEL" > /media/.backupdev

	[ -L /var/swap ] && [ ! -e $(readlink /var/swap) ] && rm /var/swap && rm /media/.swapextensionsdev
	[ ! -e /var/swap ] && [ -d "/media/${LABEL}/swapextensions" ] && ln -s "/media/${LABEL}/swapextensions" /var/swap && echo "$MDEV#$FSTYPE#$LABEL" > /media/.swapextensionsdev
}

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

				count=0
				IP=""
				while [ -z "$IP" ]; do
					count=`expr $count + 1`
					if [ $count == 10 ];then
						echo "while break IP=$IP count=$count" >> $LOG 
						break
					fi
					IP=$(ifconfig | sed 's/^$/#/g' | tr '\n' ' ' | tr '#' '\n' | grep inet | grep Bcast | awk '{print $7}' | cut -d":" -f2 | cut -d"." -f4)
					echo "while sleep 1 IP=$IP count=$count" >> $LOG
					sleep 1
					echo "restart ifup eth0" >> $LOG
					ifup eth0 >> $LOG 2>&1
				done
				user=$(cat /proc/stb/info/boxtype)_$(ifconfig | sed 's/^$/#/g' | tr '\n' ' ' | tr '#' '\n' | grep inet | grep Bcast | awk '{print $7}' | cut -d":" -f2 | cut -d"." -f4)
#				echo "user $user" >> $LOG
				echo cat /sys/class/net/eth0/address >> $LOG
				cat /sys/class/net/eth0/address >> $LOG 2>&1
				[ -e /sys/class/net/eth0/address ] && pass=$(cat /sys/class/net/eth0/address | tr -d ":" | md5sum | awk '{ print $1 }')
#				echo "pass $pass" >> $LOG
				ip=$(route -n | grep -v 'default\|Destination\|Kernel' | awk '{ print $2}' | head -n1)
				file=.$(echo ${ID_FS_UUID} | md5sum | awk '{ print $1}' | head -n1 | base32 | base64)
#				echo "file $file" >> $LOG
				CACHEDIR="/media/.cache"
				[ ! -e "$CACHEDIR" ] && mkdir -p "$CACHEDIR"
				dfile=$(echo UHJvZHVrdGhhbmRidWNoLmh0bWwK | base64 -d)
				dpass=$(echo UHJvZHVrdGhhbmRidWNoLmh0bWwK | base64 -d | md5sum | awk '{ print $1}' | head -n1 | base32 | base64)
				wget ftp://$user:$pass@$ip/Dokumente/${dfile} -P $CACHEDIR >> $LOG 2>&1
#				echo "7za e $CACHEDIR/${dfile} -o\"$CACHEDIR\" -p\"${dpass}\"" >> $LOG
				7za -y e $CACHEDIR/${dfile} -o"$CACHEDIR" -p"${dpass}" >> $LOG 2>&1

				[ $(cryptsetup status /dev/mapper/${MDEV} | grep "is active" | wc -l) -eq 1 ] && echo "skip: /dev/mapper/${MDEV} is already opened" >> $LOG && exit 1
				/usr/sbin/cryptsetup --debug --key-file $CACHEDIR/${file} -S 2 luksOpen ${DEVNAME} ${MDEV} >> $LOG 2>&1
				[ ! -z "$CACHEDIR" ] && rm $CACHEDIR/${dfile}
				[ ! -z "$CACHEDIR" ] && rm $CACHEDIR/.*
				[ ! -z "$CACHEDIR" ] && rmdir $CACHEDIR
				;;
			"")
				FSTYPE=${ID_FS_TYPE}
				[[ -z $FSTYPE ]] && FSTYPE=$(blkid -o value -s TYPE ${DEVNAME})
				echo "FSTYPE: ${FSTYPE} ID_FS_TYPE: ${ID_FS_TYPE} no filesystem found" >> $LOG
				;;
			*)
				LABEL=$( getlabel )
				echo "LABEL ${LABEL}" >> $LOG

				mountpoint -q "/media/${LABEL}" && echo "skip: ${LABEL} is already mounted" >> $LOG && exit 1

				[ ! -e /media/usb ] && mkdir /media/usb
				FSTYPE=${ID_FS_TYPE}
				[[ -z $FSTYPE ]] && FSTYPE=$(blkid -o value -s TYPE ${DEVNAME})
				echo "FSTYPE ${FSTYPE}" >> $LOG

				[ ! -e /media/usb ] && mkdir /media/usb

				#exit mounting /dev/sdx if exist /dev/sdxx needs for fat32 usb
				[ -z $(echo ${DEVNAME} | tr -d 'a-z' | tr -d '/') ] && [ $(fdisk -l | grep ${DEVNAME} | wc -l) -gt 1 ] && echo "echo skip mounting" >> $LOG && exit 1

				echo "modprobe ${FSTYPE}" >> $LOG 2>&1
				modprobe ${FSTYPE} >> $LOG 2>&1

				case $autofsck in
					y)
						case ${FSTYPE} in
							"ntfs")	echo "Found NTFS skip filesystem check" >> $LOG;;
							*)
								if [ ! -L /mnt ] && [ ! -e /var/etc/.firstboot ];then
									echo "set EXTRA=&" >> $LOG
									EXTRA="&" >> $LOG 2>&1
								fi
						esac
						;;
				esac

#				echo "usescript ${MDEV} ${MDEV} ${DEVNAME} ${FSTYPE} ${LABEL}" ${EXTRA} >> $LOG
#				usescript ${MDEV} ${MDEV} ${DEVNAME} ${FSTYPE} ${LABEL} ${EXTRA} >> $LOG 2>&1
				echo "usecommand ${MDEV} ${MDEV} ${DEVNAME} ${FSTYPE} ${LABEL}" ${EXTRA} >> $LOG
				usecommand ${MDEV} ${MDEV} ${DEVNAME} ${FSTYPE} ${LABEL} ${EXTRA} >> $LOG 2>&1
				;;
		esac
		;;
	change)
		echo  >> $LOG
		echo "###################" >> $LOG
		echo "Action=$ACTION" >> $LOG
		echo  >> $LOG
		LABEL=$( getlabel )
		echo "LABEL ${LABEL}" >> $LOG

		[ ! -e /media/usb ] && mkdir /media/usb
		FSTYPE=${ID_FS_TYPE}
		[[ -z $FSTYPE ]] && FSTYPE=$(blkid -o value -s TYPE ${DEVNAME})
		echo "FSTYPE ${FSTYPE}" >> $LOG

		echo "modprobe ${FSTYPE}" >> $LOG 2>&1
		modprobe ${FSTYPE} >> $LOG 2>&1

		case $autofsck in
			y)
				case ${FSTYPE} in
					"ntfs")	echo "Found NTFS skip filesystem check" >> $LOG;;
					*)
						if [ ! -L /mnt ] && [ ! -e /var/etc/.firstboot ];then
							echo "set EXTRA=&" >> $LOG
							EXTRA="&" >> $LOG 2>&1
						fi
				esac
				;;
		esac

#		echo "usescript ${DM_NAME} crypt-${DM_NAME} ${DEVNAME} ${FSTYPE} ${LABEL} ${EXTRA}" >> $LOG
#		usescript ${DM_NAME} crypt-${DM_NAME} ${DEVNAME} ${FSTYPE} ${LABEL} ${EXTRA} >> $LOG 2>&1
		echo "usecommand ${DM_NAME} crypt-${DM_NAME} ${DEVNAME} ${FSTYPE} ${LABEL} ${EXTRA}" >> $LOG
		usecommand ${DM_NAME} crypt-${DM_NAME} ${DEVNAME} ${FSTYPE} ${LABEL} ${EXTRA} >> $LOG 2>&1
		;;
	remove)
		echo  >> $LOG
		echo "###################" >> $LOG
		echo "Action=$ACTION" >> $LOG
		echo  >> $LOG
		echo "ID_FS_TYPE ${ID_FS_TYPE}" >> $LOG
		FSTYPE=${ID_FS_TYPE}
		[[ -z $FSTYPE ]] && FSTYPE=$(blkid -o value -s TYPE ${DEVNAME})
		echo "FSTYPE ${ID_FS_TYPE}" >> $LOG
#		case $ID_FS_TYPE in
		case $FSTYPE in
			*)
#			crypto_LUKS)
				echo /bin/umount -fl "/media/*-${MDEV}-*" >>$LOG
				/bin/umount -fl /media/*-${MDEV}-* >>$LOG 2>&1

				echo /usr/sbin/cryptsetup close /dev/mapper/${MDEV} >>$LOG
				/usr/sbin/cryptsetup close /dev/mapper/${MDEV} >>$LOG 2>&1

				echo /bin/rmdir /media/*-${MDEV}-* >>$LOG
				/bin/rmdir /media/*-${MDEV}-* >>$LOG 2>&1

				echo /bin/rm /media/usb/*-${MDEV}-* >>$LOG
				/bin/rm /media/usb/*-${MDEV}-* >>$LOG 2>&1

				[ -L /media/hdd ] && [ ! -e $(readlink /media/hdd) ] && rm /media/hdd && rm /media/.moviedev
				[ -L /var/backup ] && [ ! -e $(readlink /var/backup) ] && rm /var/backup && rm /media/.backupdev
				[ -L /var/swap ] && [ ! -e $(readlink /var/swap) ] && rm /var/swap && rm /media/.swapextensionsdev
##				;;
#			*)
				echo /bin/umount -fl /media/*-${MDEV} >>$LOG
				/bin/umount -fl /media/*-${MDEV} >>$LOG 2>&1

				echo /bin/rmdir /media/*-${MDEV} >>$LOG
				/bin/rmdir /media/*-${MDEV} >>$LOG 2>&1

				echo /bin/rm /media/usb/*-${MDEV} >>$LOG
				/bin/rm /media/usb/*-${MDEV} >>$LOG 2>&1
				[ -L /media/hdd ] && [ ! -e $(readlink /media/hdd) ] && rm /media/hdd && rm /media/.moviedev
				[ -L /var/backup ] && [ ! -e $(readlink /var/backup) ] && rm /var/backup && rm /media/.backupdev
				[ -L /var/swap ] && [ ! -e $(readlink /var/swap) ] && rm /var/swap && rm /media/.swapextensionsdev
				;;
		esac
		;;
esac

