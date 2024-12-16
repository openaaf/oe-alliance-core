#!/bin/sh

#LOG='/etc/udev/mdev-mount.log'
LOG='/media/logs/mdev.log'

# (e)udev compatibility
[[ -z $MDEV ]] && MDEV=$(basename $DEVNAME)

BLACKLISTED="mmcblk0"
FIRST_MEDIA="hdd"

## device information log
echo  >> $LOG
echo  >> $LOG
echo "**************************" >> $LOG
echo  >> $LOG
echo "Action= "$ACTION >> $LOG
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


notify() {
	exit 0
	# we don't really depend on the hotplug_e2_helper, but when it exists, call it
	if [ -x /usr/bin/hotplug_e2_helper ] ; then
		/usr/bin/hotplug_e2_helper $ACTION /dev/$MDEV /block/$DEVBASE/device
	fi
	hotplug.sh $ACTION $MDEV $DEVPATH $DEVTYPE
}

case $ACTION in
	add|change|"")
#		ACTION="add"
		usemount=2
		if [ "$1" == "cryptsetup" ]; then
			MDEV=$2
			FSTYPE=`blkid /dev/${MDEV} | grep -v 'TYPE="swap"' | grep ${MDEV} | sed -nr 's/.*TYPE="([^"]+)".*/\1/p'`
			PARTUUID=`blkid /dev/${MDEV} | grep -v 'TYPE="swap"' | grep ${MDEV} | sed -nr 's/.*PARTUUID="([^"]+)".*/\1/p'`

			if [ "$FSTYPE" == "crypto_LUKS" ]; then
				[ ! -e /media/logs ] && mkdir /media/logs
				echo "/usr/sbin/cryptsetup --debug --key-file /home/root/$PARTUUID -S 3 luksOpen /dev/$MDEV $MDEV" >>/media/logs/crypt.log
				/usr/sbin/cryptsetup --debug --key-file /home/root/$PARTUUID -S 3 luksOpen /dev/$MDEV $MDEV >>/media/logs/crypt.log 2>&1
				echo "############################" >>/media/logs/crypt.log
			fi
		else
			if [ "$1" == "mount" ] || [ "${ACTION}" == "change" ]; then
		#		MDEV=$2
		#		DEV=$(basename $DEVNAME)
				DEV=$MDEV
				MDEV=$2
			fi

			ismounted=0

			BLACKLISTED="mmcblk0"
			FIRST_MEDIA="hdd"
			if [ "$1" == "mount" ] || [ "${ACTION}" == "change" ]; then
				DEVDIR="/dev/mapper"
				MISCNAMEEXTRA="crypt-"
			else
				DEVDIR="/dev"
				MISCNAMEEXTRA=""
			fi

			FSTYPE=`blkid ${DEVDIR}/${MDEV} | grep -v 'TYPE="swap"' | grep ${MDEV} | sed -nr 's/.*TYPE="([^"]+)".*/\1/p'`
			LABEL=`blkid ${DEVDIR}/${MDEV} | grep -v 'TYPE="swap"' | grep ${MDEV} | sed -nr 's/.*LABEL="([^"]+)".*/\1/p'`

			case ${LABEL} in
				"")	if [ $(echo "${MDEV}" | grep "mmcblk0" | wc -l) -eq 1 ];then 
						LABEL="FLASH-${MDEV}"
					else
						LABEL="NONLABEL-${MDEV}"
					fi
					;;
				*)	LABEL="${LABEL}-${MDEV}";;
			esac

			case ${DEV} in
				"")	LABEL="${LABEL}";;
				*)	LABEL="${LABEL}-(${DEV})";;
			esac

			case ${ACTION} in
				"")	LABEL="${LABEL}";;
				*)	LABEL="${LABEL}-(${ACTION})";;
			esac

			if [ -z "$FSTYPE" ] ; then
				exit 0
			fi
			# check if already mounted
			if grep -q "^${DEVDIR}/${MDEV} " /proc/mounts ; then
				# Already mounted
				exit 0
			fi
			if [ -e /proc/stb/info/boxtype ]; then
				stbcheck=`cat /proc/stb/info/boxtype`
				# detected multiboot sdcard
				if [ $stbcheck == "viper4k" ] || [ $stbcheck == "sf8008" ] || [ $stbcheck == "sf8008m" ] || [ $stbcheck == "ustym4kpro" ] || [ $stbcheck == "beyonwizv2" ] || [ $stbcheck == "gbmv200" ]; then
					DEVCHECK=`expr substr $MDEV 1 3`
					if [ "${DEVCHECK}" == "sda" ] ; then
						DEVSIZE=`cat /sys/block/sda/sda1/size`
						if [ $DEVSIZE -lt "32769" ]; then
							BLACKLISTED=`echo ${BLACKLISTED} sda`
						fi
					fi
				fi
			fi
			DEVCHECK=`expr substr $MDEV 1 7`
			DEVCHECK2=`expr substr $MDEV 1 3`

			# blacklisted devices
			for black in $BLACKLISTED; do
				if [ "$DEVCHECK" == "$black" ] || [ "$DEVCHECK2" == "$black" ] ; then
					exit 0
				fi
			done
			DEVCHECK=`expr substr $MDEV 1 6`
			if [ "${DEVCHECK}" == "mmcblk" ] ; then
				DEVBASE=`expr substr $MDEV 1 7`
				PARTNUM=`expr substr $MDEV 9 1`
			else
				DEVBASE=`expr substr $MDEV 1 3`
				PARTNUM=`expr substr $MDEV 4 1`
			fi
			# check for "please don't mount it" file
			if [ -f "${DEVDIR}/nomount.${DEVBASE}" ] ; then
				# blocked
				exit 0
			fi
			# check for full-disk partition
			if [ "${DEVBASE}" == "${MDEV}" ] ; then
				if [ -d /sys/block/${DEVBASE}/${DEVBASE}1 -o -d /sys/block/${DEVBASE}/${DEVBASE}p1 ] ; then
					# Partition detected, just tell and quit
					notify
					exit 0
				fi
				if [ ! -f /sys/block/${DEVBASE}/size ] ; then
					# No size at all
					exit 0
				fi
				if [ `cat /sys/block/${DEVBASE}/size` == 0 ] ; then
					# empty device, bail out
					exit 0
				fi
			fi
			echo "[mdev-mount.sh] usemount=$usemount" >> $LOG
			if [ "$usemount" == "1" ];then
				if [ "$FSTYPE" == "ext2" ] || [ "$FSTYPE" == "ext3" ] || [ "$FSTYPE" == "ext4" ] || [ "$FSTYPE" == "xfs" ] || [ "$FSTYPE" == "jfs" ]; then
					[ ! -e /media/logs ] && mkdir /media/logs
					echo "/sbin/fsck.$FSTYPE -f -p ${DEVDIR}/${MDEV} ACTION=$ACTION 1=$1 2=$2" >>$LOG
					echo "/sbin/fsck.$FSTYPE -f -p ${DEVDIR}/${MDEV} ACTION=$ACTION 1=$1 2=$2" >>/media/logs/fsck.log
					/sbin/fsck.$FSTYPE -f -p ${DEVDIR}/${MDEV} >>/media/logs/fsck.log 2>&1
					echo "############################" >>/media/logs/fsck.log
				fi

				# due to multiple calls of mdev mount only first partition as usual, others as devicename.
				# first allow fstab to determine the mountpoint
				if ! mount ${DEVDIR}/$MDEV > /dev/null 2>&1 ; then
					echo "[mdev-mount.sh] no fstab entry, use automatic mountpoint" >> $LOG
					# no fstab entry, use automatic mountpoint
					REMOVABLE=`cat /sys/block/$DEVBASE/removable`
					readlink -fn /sys/block/$DEVBASE/device | grep -qs 'pci\|ahci'
					EXTERNAL=$?
					if [ "${REMOVABLE}" -eq "0" -a $EXTERNAL -eq 0 ] ; then
						echo "[mdev-mount.sh] non removable, non external" >> $LOG
						if [ $PARTNUM -le "1" ] ; then
							echo "[mdev-mount.sh] 1st partition found" >> $LOG
							# mount the first non-removable internal device on /media/hdd
							DEVICETYPE="hdd"
							# if mount /media/hdd already exits but an internal hdd is now found  
							# then remount the first device to the device name or to /media/usb
							# (unless the mounted device is already an internal non-removable device)
							if grep -q "/media/hdd" /proc/mounts ; then
								echo "[mdev-mount.sh] /media/hdd exists" >> $LOG
								TEMPDEV=`cat /proc/mounts | grep /media/hdd | cut -d' ' -f 1`
								# check if mounted device is already an internal device
								DEVBASE_MOUNTED=`expr substr $TEMPDEV 6 3`
								REMOVABLE_MOUNTED=`cat /sys/block/$DEVBASE_MOUNTED/removable`
								readlink -fn /sys/block/$DEVBASE_MOUNTED/device | grep -qs 'pci\|ahci'
								EXTERNAL_MOUNTED=$?
								if [ ${REMOVABLE_MOUNTED} -eq 0 -a ${EXTERNAL_MOUNTED} -eq 0 ] ; then
									echo "[mdev-mount.sh] $TEMPDEV non removable, non external" >> $LOG
									# mounted device is an internal device --> mount new internal device
									DEVICETYPE=$MDEV   
								else
									echo "[mdev-mount.sh] $TEMPDEV removable or external" >> $LOG
									# switch mounts
									TEMPDEV1=`echo ${TEMPDEV} | cut -d'/' -f 3`
									umount /media/hdd || umount ${TEMPDEV}
									echo "[mdev-mount.sh] umounted /media/hdd (preparing swap with new device found)" >> $LOG
									# Use mkdir as 'atomic' action, failure means someone beat us to the punch
									if grep -q "/media/usb" /proc/mounts ; then
										echo "[mdev-mount.sh] /media/usb exists 1" >> $LOG
										# usb mountpoint is used --> use divicefile as usual
										MOUNTPOINT="/media/$MDEV"
									else
										echo "[mdev-mount.sh] /media/usb doesnt exist 1" >> $LOG
										MOUNTPOINT="/media/usb"
									fi
									# Remove mountpoint not being used
									if [ -z "`grep $MOUNTPOINT /proc/mounts`" ] ; then
										find $MOUNTPOINT -type d -delete
										[ -d $MOUNTPOINT ] && rmdir $MOUNTPOINT
									fi
									if ! mkdir $MOUNTPOINT ; then
										MOUNTPOINT="/media/$TEMPDEV1"
										mkdir -p $MOUNTPOINT
									fi
									if ! mount -t auto ${TEMPDEV} "${MOUNTPOINT}" ; then
										if ! mount.exfat ${TEMPDEV} "${MOUNTPOINT}" ; then
											echo "[mdev-mount.sh] mount failed 1" >> $LOG
											find "${MOUNTPOINT}" -type d -delete
											[ -d $MOUNTPOINT ] && rmdir "${MOUNTPOINT}"
										else
											ismounted=1
											[ $MOUNTPOINT == "/media/hdd" ] && echo "$MDEV#$FSTYPE#$LABEL" > /media/.moviedev
											[ -L /var/backup ] && [ ! -e $(readlink /var/backup) ] && rm /var/backup && rm /media/.backupdev
											[ ! -e /var/backup ] && [ -d $MOUNTPOINT/backup ] && ln -fs "${MOUNTPOINT}/backup" /var/backup && echo "$MDEV#$FSTYPE#$LABEL" > /media/.backupdev
											[ -L /var/swapextensions ] && [ ! -e $(readlink /var/swapextensions) ] && rm /var/swapextensions && /media/.swapextensionsdev
											[ ! -e /var/swapextensions ] && [ -d $MOUNTPOINT/swapextensions ] && ln -sf "${MOUNTPOINT}/swapextensions" /var/swapextensions && echo "$MDEV#$FSTYPE#$LABEL" > /media/.swapextensionsdev
										fi
									else
										ismounted=1
										[ $MOUNTPOINT == "/media/hdd" ] && echo "$MDEV#$FSTYPE#$LABEL" > /media/.moviedev
										[ -L /var/backup ] && [ ! -e $(readlink /var/backup) ] && rm /var/backup && rm /media/.backupdev
										[ ! -e /var/backup ] && [ -d $MOUNTPOINT/backup ] && ln -fs "${MOUNTPOINT}/backup" /var/backup && echo "$MDEV#$FSTYPE#$LABEL" > /media/.backupdev
										[ -L /var/swapextensions ] && [ ! -e $(readlink /var/swapextensions) ] && rm /var/swapextensions && /media/.swapextensionsdev
										[ ! -e /var/swapextensions ] && [ -d $MOUNTPOINT/swapextensions ] && ln -sf "${MOUNTPOINT}/swapextensions" /var/swapextensions && echo "$MDEV#$FSTYPE#$LABEL" > /media/.swapextensionsdev
									fi
									echo "[mdev-mount.sh] mounted $MDEV on $MOUNTPOINT (swap complete)" >> $LOG
								fi
							fi
						else
							echo "[mdev-mount.sh] next partition $PARTNUM of non USB device found" >> $LOG
							# Mount next partition as detected device
							DEVICETYPE=$MDEV
						fi
					else
						echo "[mdev-mount.sh] removable or external" >> $LOG
						MODEL=`cat /sys/block/$DEVBASE/device/model`
						MODEL1=`cat /sys/block/$DEVBASE/device/type`
						if [ "$MODEL" == "USB CF Reader     " ]; then
							DEVICETYPE="cf"
						elif [ "$MODEL" == "Compact Flash   " ]; then
							DEVICETYPE="cf"
						elif [ "$MODEL" == "USB SD Reader   " ]; then
							DEVICETYPE="mmc"
						elif [ "$MODEL" == "USB SD  Reader  " ]; then
							DEVICETYPE="mmc"
						elif [ "$MODEL" == "SD/MMC          " ]; then
							DEVICETYPE="mmc"
						elif [ "$MODEL" == "USB MS Reader   " ]; then
							DEVICETYPE="mmc"
						elif [ "$MODEL" == "SM/xD-Picture   " ]; then
							DEVICETYPE="mmc"
						elif [ "$MODEL" == "USB SM Reader   " ]; then
							DEVICETYPE="mmc"
						elif [ "$MODEL" == "MS/MS-Pro       " ]; then
							DEVICETYPE="mmc"
						elif [ "$MODEL1" == "SD	            " ]; then
							DEVICETYPE="mmc"
						elif [ "$MODEL1" == "SD              " ]; then
							DEVICETYPE="mmc"
						elif [ "$MODEL1" == "SD" ]; then
							DEVICETYPE="mmc"
						else
							echo "[mdev-mount.sh] USB device found" >> $LOG
							if [ $PARTNUM -eq "1" -o $PARTNUM -eq "5" ] ; then
								echo "[mdev-mount.sh] 1st partition found" >> $LOG
								if grep -q "/media/hdd" /proc/mounts ; then
									echo "[mdev-mount.sh] /media/hdd exists" >> $LOG
									if grep -q "/media/usb" /proc/mounts ; then
										echo "[mdev-mount.sh] /media/usb exists" >> $LOG
										DEVICETYPE=$MDEV
									else
										DEVICETYPE="usb"
									fi
								else
									# mount the first removable device on /media/hdd only when no other internal hdd is present
									DEVICETYPE="hdd"
									DEVLIST=`ls -1 /sys/block | grep "sd[a-z]\|mmcblk[0-9]"`
									for DEV in $DEVLIST; do
										DEVBASE=`expr substr $DEV 1 3`
										readlink -fn /sys/block/$DEVBASE/device | grep -qs 'pci\|ahci'
										EXTERNAL=$?
										if [ "${REMOVABLE}" -eq "0" -a $EXTERNAL -eq 0 ] ; then
											DEVICETYPE="usb"
											echo "[mdev-mount.sh] internal sdx detected -> mount as USB" >> $LOG
											break
										fi
									done
								fi
							else
								echo "[mdev-mount.sh] next partition $PARTNUM of USB device found" >> $LOG
								# Mount next partition as detected device
								DEVICETYPE=$MDEV
							fi
						fi
					fi
					# Use mkdir as 'atomic' action, failure means someone beat us to the punch
					MOUNTPOINT="/media/$DEVICETYPE"

					# Remove mountpoint not being used
					if [ -z "`grep $MOUNTPOINT /proc/mounts`" ] ; then
						echo "[mdev-mount.sh] rmdir $MOUNTPOINT" >> $LOG
						find $MOUNTPOINT  -type d -delete
						[ -d $MOUNTPOINT ] && rmdir $MOUNTPOINT
					fi
					if ! mkdir $MOUNTPOINT ; then
						echo "[mdev-mount.sh] mkdir $MOUNTPOINT failed, using /media/$MDEV" >> $LOG
						MOUNTPOINT="/media/$MDEV"
						mkdir -p $MOUNTPOINT
					fi

#					if [ "$FSTYPE" == "ext2" ] || [ "$FSTYPE" == "ext3" ] || [ "$FSTYPE" == "ext4" ] || [ "$FSTYPE" == "jfs" ]; then
#						echo "/sbin/fsck.$FSTYPE -f -p ${DEVDIR}/${MDEV} ACTION=$ACTION 1=$1 2=$2" >>$LOG
#						/sbin/fsck.$FSTYPE -f -p ${DEVDIR}/${MDEV} >>$LOG 2>&1
#					fi

					if ! mount -t auto ${DEVDIR}/${MDEV} "${MOUNTPOINT}" ; then
						if ! mount.exfat ${DEVDIR}/$MDEV "${MOUNTPOINT}" ; then
							echo "[mdev-mount.sh] mount failed 2" >> $LOG
							find "${MOUNTPOINT}" -type d -delete
							[ -d $MOUNTPOINT ] && rmdir "${MOUNTPOINT}"
						else
							ismounted=1
							echo "[mdev-mount.sh] mount ok 2" >> $LOG
							[ $MOUNTPOINT == "/media/hdd" ] && echo "$MDEV#$FSTYPE#$LABEL" > /media/.moviedev
							[ -L /var/backup ] && [ ! -e $(readlink /var/backup) ] && rm /var/backup && rm /media/.backupdev
							[ ! -e /var/backup ] && [ -d $MOUNTPOINT/backup ] && ln -fs "${MOUNTPOINT}/backup" /var/backup && echo "$MDEV#$FSTYPE#$LABEL" > /media/.backupdev
							[ -L /var/swapextensions ] && [ ! -e $(readlink /var/swapextensions) ] && rm /var/swapextensions && /media/.swapextensionsdev
							[ ! -e /var/swapextensions ] && [ -d $MOUNTPOINT/swapextensions ] && ln -sf "${MOUNTPOINT}/swapextensions" /var/swapextensions && echo "$MDEV#$FSTYPE#$LABEL" > /media/.swapextensionsdev
						fi
					else
						ismounted=1
						echo "[mdev-mount.sh] mount ok 1" >> $LOG
						[ $MOUNTPOINT == "/media/hdd" ] && echo "$MDEV#$FSTYPE#$LABEL" > /media/.moviedev
						[ -L /var/backup ] && [ ! -e $(readlink /var/backup) ] && rm /var/backup && rm /media/.backupdev
						[ ! -e /var/backup ] && [ -d $MOUNTPOINT/backup ] && ln -fs "${MOUNTPOINT}/backup" /var/backup && echo "$MDEV#$FSTYPE#$LABEL" > /media/.backupdev
						[ -L /var/swapextensions ] && [ ! -e $(readlink /var/swapextensions) ] && rm /var/swapextensions && /media/.swapextensionsdev
						[ ! -e /var/swapextensions ] && [ -d $MOUNTPOINT/swapextensions ] && ln -sf "${MOUNTPOINT}/swapextensions" /var/swapextensions && echo "$MDEV#$FSTYPE#$LABEL" > /media/.swapextensionsdev
					fi
				fi

			elif [ "$usemount" == "2" ];then
				if [ "$FSTYPE" == "ext2" ] || [ "$FSTYPE" == "ext3" ] || [ "$FSTYPE" == "ext4" ] || [ "$FSTYPE" == "xfs" ] || [ "$FSTYPE" == "jfs" ]; then
					[ ! -e /media/logs ] && mkdir /media/logs
					echo "/sbin/fsck.$FSTYPE -f -p ${DEVDIR}/${MDEV} ACTION=$ACTION 1=$1 2=$2" >>/media/logs/fsck.log
					/sbin/fsck.$FSTYPE -f -p ${DEVDIR}/${MDEV} >>/media/logs/fsck.log 2>&1
					echo "############################" >>/media/logs/fsck.log
				fi

				# due to multiple calls of mdev mount only first partition as usual, others as devicename.
				# first allow fstab to determine the mountpoint
				if ! mount ${DEVDIR}/$MDEV > /dev/null 2>&1 ; then
					echo "[mdev-mount.sh] no fstab entry, use automatic mountpoint" >> $LOG

					MOUNTPOINT=/media/check_hdd_type
					mkdir $MOUNTPOINT
					echo "mount -t auto ${DEVDIR}/$MDEV ${MOUNTPOINT}" >> $LOG
					if ! mount -t auto ${DEVDIR}/$MDEV "${MOUNTPOINT}" ; then
						echo "[mdev-mount.sh] mount failed 0" >> $LOG
						if [ -z "`grep $MOUNTPOINT /proc/mounts`" ] ; then
							echo "[mdev-mount.sh] mount failed 0 > remove not mounted $MOUNTPOINT" >> $LOG
							find "${MOUNTPOINT}" -type d -delete
							[ -d $MOUNTPOINT ] && rmdir "${MOUNTPOINT}"
						fi
					else
						echo "[mdev-mount.sh] mount ok 0" >> $LOG
						ismounted=1
##						[ -L /media/hdd-neu ] && [ ! -e $(readlink /media/hdd-neu) ] && rm /media/hdd-neu && rm /media/.moviedev
#						[ ! -e /media/hdd-neu ] && [ -d $MOUNTPOINT/movie ] && ln -s "/media/autofs/${MISCNAMEEXTRA}${MDEV}/movie" /media/hdd-neu && echo "$MDEV#$FSTYPE#$LABEL" > /media/.moviedev

						[ -d $MOUNTPOINT/movie ] && [ -d /media/hdd ] && umount /media/hdd && rmdir /media/hdd && rm /media/.moviedev && ln -s "/media/autofs/${MISCNAMEEXTRA}${MDEV}" /media/hdd && echo "$MDEV#$FSTYPE#$LABEL" > /media/.moviedev
						[ ! -e /media/hdd ] && [ -d $MOUNTPOINT/movie ] && ln -s "/media/autofs/${MISCNAMEEXTRA}${MDEV}" /media/hdd && echo "$MDEV#$FSTYPE#$LABEL" > /media/.moviedev

#						[ -L /var/backup ] && [ ! -e $(readlink /var/backup) ] && rm /var/backup && rm /media/.backupdev
						[ ! -e /var/backup ] && [ -d $MOUNTPOINT/backup ] && ln -s "/media/autofs/${MISCNAMEEXTRA}${MDEV}/backup" /var/backup && echo "$MDEV#$FSTYPE#$LABEL" > /media/.backupdev

#						[ -L /var/swapextensions ] && [ ! -e $(readlink /var/swapextensions) ] && rm /var/swapextensions && rm /media/.swapextensionsdev
						[ ! -e /var/swapextensions ] && [ -d $MOUNTPOINT/swapextensions ] && ln -s "/media/autofs/${MISCNAMEEXTRA}${MDEV}/swapextensions" /var/swapextensions && echo "$MDEV#$FSTYPE#$LABEL" > /media/.swapextensionsdev
					fi
					umount ${MOUNTPOINT}
					if [ -z "`grep $MOUNTPOINT /proc/mounts`" ] ; then
						echo "[mdev-mount.sh] remove not mounted $MOUNTPOINT" >> $LOG
						find "${MOUNTPOINT}" -type d -delete
						[ -d $MOUNTPOINT ] && rmdir "${MOUNTPOINT}"
					fi
					# no fstab entry, use automatic mountpoint
					REMOVABLE=`cat /sys/block/$DEVBASE/removable`
					readlink -fn /sys/block/$DEVBASE/device | grep -qs 'pci\|ahci'
					EXTERNAL=$?
					if [ "${REMOVABLE}" -eq "0" -a $EXTERNAL -eq 0 ] ; then
						echo "[mdev-mount.sh] non removable, non external" >> $LOG
						if [ $PARTNUM -le "1" ] ; then
							echo "[mdev-mount.sh] 1st partition found" >> $LOG
							# mount the first non-removable internal device on /media/hdd
							DEVICETYPE="hdd"
							# if mount /media/hdd already exits but an internal hdd is now found  
							# then remount the first device to the device name or to /media/usb
							# (unless the mounted device is already an internal non-removable device)
#							if grep -q "/media/hdd" /proc/mounts ; then
							if grep -q "/media/hdd" /proc/mounts -o -L /media/hdd; then
#								echo "[mdev-mount.sh] /media/hdd exists" >> $LOG
								echo "[mdev-mount.sh] mount or link /media/hdd exists" >> $LOG
								TEMPDEV=`cat /proc/mounts | grep /media/hdd | cut -d' ' -f 1`
								# check if mounted device is already an internal device
								DEVBASE_MOUNTED=`expr substr $TEMPDEV 6 3`
								REMOVABLE_MOUNTED=`cat /sys/block/$DEVBASE_MOUNTED/removable`
								readlink -fn /sys/block/$DEVBASE_MOUNTED/device | grep -qs 'pci\|ahci'
								EXTERNAL_MOUNTED=$?
								if [ ${REMOVABLE_MOUNTED} -eq 0 -a ${EXTERNAL_MOUNTED} -eq 0 ] ; then
									echo "[mdev-mount.sh] $TEMPDEV non removable, non external" >> $LOG
									# mounted device is an internal device --> mount new internal device
									DEVICETYPE=$MDEV   
								else
									echo "[mdev-mount.sh] $TEMPDEV removable or external" >> $LOG
									# switch mounts
									TEMPDEV1=`echo ${TEMPDEV} | cut -d'/' -f 3`
									umount /media/hdd || umount ${TEMPDEV}
									echo "[mdev-mount.sh] umounted /media/hdd (preparing swap with new device found)" >> $LOG
									# Use mkdir as 'atomic' action, failure means someone beat us to the punch
									if grep -q "/media/usb" /proc/mounts ; then
										echo "[mdev-mount.sh] /media/usb exists 1" >> $LOG
										# usb mountpoint is used --> use divicefile as usual
										MOUNTPOINT="/media/$MDEV"
									else
										echo "[mdev-mount.sh] /media/usb doesnt exist 1" >> $LOG
										MOUNTPOINT="/media/usb"
									fi
									# Remove mountpoint not being used
									if [ -z "`grep $MOUNTPOINT /proc/mounts`" ] ; then
										find $MOUNTPOINT -type d -delete
										[ -d $MOUNTPOINT ] && rmdir $MOUNTPOINT
									fi
									if ! mkdir $MOUNTPOINT ; then
										MOUNTPOINT="/media/$TEMPDEV1"
										mkdir -p $MOUNTPOINT
									fi
									if ! mount -t auto ${TEMPDEV} "${MOUNTPOINT}" ; then
										if ! mount.exfat ${TEMPDEV} "${MOUNTPOINT}" ; then
											echo "[mdev-mount.sh] mount failed 1" >> $LOG
											find "${MOUNTPOINT}" -type d -delete
											[ -d $MOUNTPOINT ] && rmdir "${MOUNTPOINT}"
										else
											ismounted=1
											[ $MOUNTPOINT == "/media/hdd" ] && echo "$MDEV#$FSTYPE#$LABEL" > /media/.moviedev
#											[ -L /var/backup ] && [ ! -e $(readlink /var/backup) ] && rm /var/backup && rm /media/.backupdev
#											[ ! -e /var/backup ] && [ -d $MOUNTPOINT/backup ] && ln -fs "${MOUNTPOINT}/backup" /var/backup && echo "$MDEV#$FSTYPE#$LABEL" > /media/.backupdev
#											[ -L /var/swapextensions ] && [ ! -e $(readlink /var/swapextensions) ] && rm /var/swapextensions && /media/.swapextensionsdev
#											[ ! -e /var/swapextensions ] && [ -d $MOUNTPOINT/swapextensions ] && ln -sf "${MOUNTPOINT}/swapextensions" /var/swapextensions && echo "$MDEV#$FSTYPE#$LABEL" > /media/.swapextensionsdev
										fi
									else
										ismounted=1
										[ $MOUNTPOINT == "/media/hdd" ] && echo "$MDEV#$FSTYPE#$LABEL" > /media/.moviedev
#										[ -L /var/backup ] && [ ! -e $(readlink /var/backup) ] && rm /var/backup && rm /media/.backupdev
#										[ ! -e /var/backup ] && [ -d $MOUNTPOINT/backup ] && ln -fs "${MOUNTPOINT}/backup" /var/backup && echo "$MDEV#$FSTYPE#$LABEL" > /media/.backupdev
#										[ -L /var/swapextensions ] && [ ! -e $(readlink /var/swapextensions) ] && rm /var/swapextensions && /media/.swapextensionsdev
#										[ ! -e /var/swapextensions ] && [ -d $MOUNTPOINT/swapextensions ] && ln -sf "${MOUNTPOINT}/swapextensions" /var/swapextensions && echo "$MDEV#$FSTYPE#$LABEL" > /media/.swapextensionsdev
									fi
									echo "[mdev-mount.sh] mounted $MDEV on $MOUNTPOINT (swap complete)" >> $LOG
								fi
							fi
						else
							echo "[mdev-mount.sh] next partition $PARTNUM of non USB device found" >> $LOG
							# Mount next partition as detected device
							DEVICETYPE=$MDEV
						fi
					else
						echo "[mdev-mount.sh] removable or external" >> $LOG
						MODEL=`cat /sys/block/$DEVBASE/device/model`
						MODEL1=`cat /sys/block/$DEVBASE/device/type`
						if [ "$MODEL" == "USB CF Reader     " ]; then
							DEVICETYPE="cf"
						elif [ "$MODEL" == "Compact Flash   " ]; then
							DEVICETYPE="cf"
						elif [ "$MODEL" == "USB SD Reader   " ]; then
							DEVICETYPE="mmc"
						elif [ "$MODEL" == "USB SD  Reader  " ]; then
							DEVICETYPE="mmc"
						elif [ "$MODEL" == "SD/MMC          " ]; then
							DEVICETYPE="mmc"
						elif [ "$MODEL" == "USB MS Reader   " ]; then
							DEVICETYPE="mmc"
						elif [ "$MODEL" == "SM/xD-Picture   " ]; then
							DEVICETYPE="mmc"
						elif [ "$MODEL" == "USB SM Reader   " ]; then
							DEVICETYPE="mmc"
						elif [ "$MODEL" == "MS/MS-Pro       " ]; then
							DEVICETYPE="mmc"
						elif [ "$MODEL1" == "SD	            " ]; then
							DEVICETYPE="mmc"
						elif [ "$MODEL1" == "SD              " ]; then
							DEVICETYPE="mmc"
						elif [ "$MODEL1" == "SD" ]; then
							DEVICETYPE="mmc"
						else
							echo "[mdev-mount.sh] USB device found" >> $LOG
							if [ $PARTNUM -eq "1" -o $PARTNUM -eq "5" ] ; then
								echo "[mdev-mount.sh] 1st partition found" >> $LOG
#								if grep -q "/media/hdd" /proc/mounts ; then
								if grep -q "/media/hdd" /proc/mounts -o -L /media/hdd; then
									echo "[mdev-mount.sh] mount or link /media/hdd exists" >> $LOG
#									echo "[mdev-mount.sh] /media/hdd exists" >> $LOG
									if grep -q "/media/usb" /proc/mounts ; then
										echo "[mdev-mount.sh] /media/usb exists" >> $LOG
										DEVICETYPE=$MDEV
									else
										DEVICETYPE="usb"
									fi
								else
									# mount the first removable device on /media/hdd only when no other internal hdd is present
									DEVICETYPE="hdd"
									DEVLIST=`ls -1 /sys/block | grep "sd[a-z]\|mmcblk[0-9]"`
									for DEV in $DEVLIST; do
										DEVBASE=`expr substr $DEV 1 3`
										readlink -fn /sys/block/$DEVBASE/device | grep -qs 'pci\|ahci'
										EXTERNAL=$?
										if [ "${REMOVABLE}" -eq "0" -a $EXTERNAL -eq 0 ] ; then
											DEVICETYPE="usb"
											echo "[mdev-mount.sh] internal sdx detected -> mount as USB" >> $LOG
											break
										fi
									done
								fi
							else
								echo "[mdev-mount.sh] next partition $PARTNUM of USB device found" >> $LOG
								# Mount next partition as detected device
								DEVICETYPE=$MDEV
							fi
						fi
					fi
					# Use mkdir as 'atomic' action, failure means someone beat us to the punch
					MOUNTPOINT="/media/$DEVICETYPE"

					# Remove mountpoint not being used
					if [ -z "`grep $MOUNTPOINT /proc/mounts`" ] ; then
						echo "[mdev-mount.sh] rmdir $MOUNTPOINT" >> $LOG
						find $MOUNTPOINT  -type d -delete
						[ -d $MOUNTPOINT ] && rmdir $MOUNTPOINT
					fi
					if ! mkdir $MOUNTPOINT ; then
						echo "[mdev-mount.sh] mkdir $MOUNTPOINT failed, using /media/$MDEV" >> $LOG
						MOUNTPOINT="/media/$MDEV"
						mkdir -p $MOUNTPOINT
					fi

#					if [ "$FSTYPE" == "ext2" ] || [ "$FSTYPE" == "ext3" ] || [ "$FSTYPE" == "ext4" ] || [ "$FSTYPE" == "jfs" ]; then
#						echo "/sbin/fsck.$FSTYPE -f -p ${DEVDIR}/${MDEV} ACTION=$ACTION 1=$1 2=$2" >>$LOG
#						/sbin/fsck.$FSTYPE -f -p ${DEVDIR}/${MDEV} >>$LOG 2>&1
#					fi

					if ! mount -t auto ${DEVDIR}/${MDEV} "${MOUNTPOINT}" ; then
						if ! mount.exfat ${DEVDIR}/$MDEV "${MOUNTPOINT}" ; then
							echo "[mdev-mount.sh] mount failed 2" >> $LOG
							find "${MOUNTPOINT}" -type d -delete
							[ -d $MOUNTPOINT ] && rmdir "${MOUNTPOINT}"
						else
							ismounted=1
							echo "[mdev-mount.sh] mount ok 2" >> $LOG
							[ $MOUNTPOINT == "/media/hdd" ] && echo "$MDEV#$FSTYPE#$LABEL" > /media/.moviedev
#							[ -L /var/backup ] && [ ! -e $(readlink /var/backup) ] && rm /var/backup && rm /media/.backupdev
#							[ ! -e /var/backup ] && [ -d $MOUNTPOINT/backup ] && ln -fs "${MOUNTPOINT}/backup" /var/backup && echo "$MDEV#$FSTYPE#$LABEL" > /media/.backupdev
#							[ -L /var/swapextensions ] && [ ! -e $(readlink /var/swapextensions) ] && rm /var/swapextensions && /media/.swapextensionsdev
#							[ ! -e /var/swapextensions ] && [ -d $MOUNTPOINT/swapextensions ] && ln -sf "${MOUNTPOINT}/swapextensions" /var/swapextensions && echo "$MDEV#$FSTYPE#$LABEL" > /media/.swapextensionsdev
						fi
					else
						ismounted=1
						echo "[mdev-mount.sh] mount ok 1" >> $LOG
						[ $MOUNTPOINT == "/media/hdd" ] && echo "$MDEV#$FSTYPE#$LABEL" > /media/.moviedev
#						[ -L /var/backup ] && [ ! -e $(readlink /var/backup) ] && rm /var/backup && rm /media/.backupdev
#						[ ! -e /var/backup ] && [ -d $MOUNTPOINT/backup ] && ln -fs "${MOUNTPOINT}/backup" /var/backup && echo "$MDEV#$FSTYPE#$LABEL" > /media/.backupdev
#						[ -L /var/swapextensions ] && [ ! -e $(readlink /var/swapextensions) ] && rm /var/swapextensions && /media/.swapextensionsdev
#						[ ! -e /var/swapextensions ] && [ -d $MOUNTPOINT/swapextensions ] && ln -sf "${MOUNTPOINT}/swapextensions" /var/swapextensions && echo "$MDEV#$FSTYPE#$LABEL" > /media/.swapextensionsdev
					fi
				fi
			else
				if [ "$FSTYPE" != "crypto_LUKS" ]; then
					ismounted=1
				fi
#				/bin/ln -sf /media/autofs/${MISCNAMEEXTRA}${MDEV} $MOUNTPOINT
#				if [ -d "/media/autofs/${MISCNAMEEXTRA}${MDEV}/movie" ]; then
#					ln -sf /media/autofs/${MISCNAMEEXTRA}${MDEV} /media/hdd
#					echo "$MDEV#$FSTYPE#$LABEL" > /media/.moviedev
#				fi
#				[ -d /media/autofs/${MISCNAMEEXTRA}${MDEV}/movie ] && echo "$MDEV#$FSTYPE#$LABEL" > /media/.moviedev


				if [ "$FSTYPE" == "ext2" ] || [ "$FSTYPE" == "ext3" ] || [ "$FSTYPE" == "ext4" ] || [ "$FSTYPE" == "xfs" ] || [ "$FSTYPE" == "jfs" ]; then
					[ ! -e /media/logs ] && mkdir /media/logs
					echo "/sbin/fsck.$FSTYPE -f -p ${DEVDIR}/${MDEV} ACTION=$ACTION 1=$1 2=$2" >>$LOG
					echo "/sbin/fsck.$FSTYPE -f -p ${DEVDIR}/${MDEV} ACTION=$ACTION 1=$1 2=$2" >>/media/logs/fsck.log
					/sbin/fsck.$FSTYPE -f -p ${DEVDIR}/${MDEV} >>/media/logs/fsck.log 2>&1
					echo "############################" >>/media/logs/fsck.log
				fi

#				/etc/init.d/autofs start >>/media/logs/autofs.log 2>&1

				sleep 0.1
				[ -L /media/hdd ] && [ ! -e $(readlink /media/hdd) ] && rm /media/hdd && rm /media/.moviedev
				[ ! -e /media/hdd ] && [ -d /media/autofs/${MISCNAMEEXTRA}${MDEV}/movie ] && ln -s "/media/autofs/${MISCNAMEEXTRA}${MDEV}/movie" /media/hdd && echo "$MDEV#$FSTYPE#$LABEL" > /media/.moviedev

				[ -L /var/backup ] && [ ! -e $(readlink /var/backup) ] && rm /var/backup && rm /media/.backupdev
				[ ! -e /var/backup ] && [ -d /media/autofs/${MISCNAMEEXTRA}${MDEV}/backup ] && ln -s "/media/autofs/${MISCNAMEEXTRA}${MDEV}/backup" /var/backup && echo "$MDEV#$FSTYPE#$LABEL" > /media/.backupdev

				[ -L /var/swapextensions ] && [ ! -e $(readlink /var/swapextensions) ] && rm /var/swapextensions && rm /media/.swapextensionsdev
				[ ! -e /var/swapextensions ] && [ -d /media/autofs/${MISCNAMEEXTRA}${MDEV}/swapextensions ] && ln -s "/media/autofs/${MISCNAMEEXTRA}${MDEV}/swapextensions" /var/swapextensions && echo "$MDEV#$FSTYPE#$LABEL" > /media/.swapextensionsdev

#				[ -L /media/backup ] && [ ! -e $(readlink /media/backup) ] && rm /media/backup && rm /media/.backupdev
#				[ ! -e /media/backup ] && [ -d /media/autofs/${MISCNAMEEXTRA}${MDEV}/backup ] && ln -s "/media/autofs/${MISCNAMEEXTRA}${MDEV}/backup" /media/backup && echo "$MDEV#$FSTYPE#$LABEL" > /media/.backupdev

#				[ -L /media/swapextensions ] && [ ! -e $(readlink /media/swapextensions) ] && rm /media/swapextensions && rm /media/.swapextensionsdev
#				[ ! -e /media/swapextensions ] && [ -d /media/autofs/${MISCNAMEEXTRA}${MDEV}/swapextensions ] && ln -s "/media/autofs/${MISCNAMEEXTRA}${MDEV}/swapextensions" /media/swapextensions && echo "$MDEV#$FSTYPE#$LABEL" > /media/.swapextensionsdev


#[ ! -e /media/logs ] && mkdir /media/logs
#echo 1. ls -al /media/autofs/${MISCNAMEEXTRA}${MDEV}/swapextensions >>/media/logs/swapextensions.log 2>&1
#ls -al /media/autofs/${MISCNAMEEXTRA}${MDEV}/swapextensions >>/media/logs/swapextensions.log 2>&1
#cat /media/.swapextensionsdev >>/media/logs/swapextensions.log 2>&1

#echo 1. ls -al /media/autofs/${MISCNAMEEXTRA}${MDEV}/backup >>/media/logs/backup.log 2>&1
#ls -al /media/autofs/${MISCNAMEEXTRA}${MDEV}/backup >>/media/logs/backup.log 2>&1
#cat /media/.backupdev >>/media/logs/backup.log 2>&1


#echo 2. ls -al /media/autofs/${MISCNAMEEXTRA}${MDEV}/backup >>/media/logs/swapextensions.log 2>&1
#ls -al /media/autofs/${MISCNAMEEXTRA}${MDEV}/backup >>/media/logs/swapextensions.log 2>&1
#cat /media/.swapextensionsdev >>/media/logs/swapextensions.log 2>&1

#echo 2. ls -al /media/autofs/${MISCNAMEEXTRA}${MDEV}/backup >>/media/logs/backup.log 2>&1
#ls -al /media/autofs/${MISCNAMEEXTRA}${MDEV}/backup >>/media/logs/backup.log 2>&1
#cat /media/.backupdev >>/media/logs/backup.log 2>&1


#if [ -d /media/autofs/${MISCNAMEEXTRA}${MDEV}/swapextensions ];then
#	ln -s "/media/autofs/${MISCNAMEEXTRA}${MDEV}/swapextensions" /var/swapextensions
#	echo "$MDEV#$FSTYPE#$LABEL" > /media/.swapextensionsdev
#fi

#				[ -L /var/swap ] && [ ! -e $(readlink /var/swap) ] && rm /var/swap && rm /media/.swapextensionsdev
##				[ -d /media/autofs/${MISCNAMEEXTRA}${MDEV}/swapextensions ] && [ -d /var/swap ] && rm -rf /var/swap && rm /media/.swapextensionsdev
#				[ ! -e /var/swap ] && [ -d /media/autofs/${MISCNAMEEXTRA}${MDEV}/swapextensions ] && ln -sf "/media/autofs/${MISCNAMEEXTRA}${MDEV}/swapextensions" /var/swap && echo "$MDEV#$FSTYPE#$LABEL" > /media/.swapextensionsdev


#				[ -L /media/hdd ] && [ ! -e $(readlink /media/hdd) ] && rm /media/hdd
#				[ -d /media/autofs/${MISCNAMEEXTRA}${MDEV}/movie ] && ln -fs "/media/autofs/${MISCNAMEEXTRA}${MDEV}/movie" /media/hdd && echo "$MDEV#$FSTYPE#$LABEL" > /media/.moviedev
#				[ -L /var/backup ] && [ ! -e $(readlink /var/backup) ] && rm /var/backup
#				[ -d /media/autofs/${MISCNAMEEXTRA}${MDEV}/backup ] && ln -fs "/media/autofs/${MISCNAMEEXTRA}${MDEV}/backup" /var/backup && echo "$MDEV#$FSTYPE#$LABEL" > /media/.backupdev
#				[ -L /var/swapextensions ] && [ ! -e $(readlink /var/swapextensions) ] && rm /var/swapextensions
#				[ -d /media/autofs/${MISCNAMEEXTRA}${MDEV}/swapextensions ] && ln -sf "/media/autofs/${MISCNAMEEXTRA}${MDEV}/swapextensions" /var/swap && echo "$MDEV#$FSTYPE#$LABEL" > /media/.swapextensionsdev

#				[ -L /media/hdd ] && [ ! -e $(readlink /media/hdd) ] && rm /media/hdd
#				[ -d /media/autofs/${MISCNAMEEXTRA}${MDEV}/movie ] && ln -fs "/media/autofs/${MISCNAMEEXTRA}${MDEV}/movie" /media/hdd && echo "$MDEV#$FSTYPE#$LABEL" > /media/.moviedev
#				[ -L /var/backup ] && [ ! -e $(readlink /var/backup) ] && rm /var/backup
#				[ -d /media/autofs/${MISCNAMEEXTRA}${MDEV}/backup ] && ln -fs "/media/autofs/${MISCNAMEEXTRA}${MDEV}/backup" /var/backup && echo "$MDEV#$FSTYPE#$LABEL" > /media/.backupdev
#				[ -L /var/swap ] && [ ! -e $(readlink /var/swap) ] && rm /var/swap
#				[ -d /media/autofs/${MISCNAMEEXTRA}${MDEV}/swapextensions ] && [ -d /var/swap ] && rm -rf /var/swap
#				[ -d /media/autofs/${MISCNAMEEXTRA}${MDEV}/swapextensions ] && ln -sf "/media/autofs/${MISCNAMEEXTRA}${MDEV}/swapextensions" /var/swap && echo "$MDEV#$FSTYPE#$LABEL" > /media/.swapextensionsdev
			fi

			if [ "$ismounted" == "1" ];then
				[ ! -e /media/usb-oenew ] && mkdir /media/usb-oenew
				[ ! -e /media/usb-oenew/${LABEL} ] && /bin/ln -s /media/autofs/${MISCNAMEEXTRA}${MDEV} "/media/usb-oenew/${LABEL}"
			fi
		fi

		;;
	remove)
		if [ "$usemount" == "1" ];then
			MOUNTPOINT=`grep "^/dev/$MDEV\s" /proc/mounts | cut -d' ' -f 2`
			if [ -z "$MOUNTPOINT" ] ; then
				MOUNTPOINT="/media/$MDEV"
			fi
			umount $MOUNTPOINT || umount /dev/$MDEV
			find $MOUNTPOINT  -type d -delete
			[ -d $MOUNTPOINT ] && rmdir $MOUNTPOINT
			[ $MOUNTPOINT == "/media/hdd" ] && rm /media/.moviedev
			[ -L /var/backup ] && [ $(readlink /var/backup) == $MOUNTPOINT/backup ] && rm /var/backup && rm /media/.backupdev
			[ -L /var/swapextensions ] && [ $(readlink /var/swap) == $MOUNTPOINT/swapextensions ] && rm /var/swap && rm /media/.swapextensionsdev
			#echo "[mdev-mount.sh] umounted $MOUNTPOINT" >> $LOG
		else
			MOUNTPOINT=`grep "^$MDEV\s" /proc/mounts | cut -d' ' -f 2`
			umount $MOUNTPOINT || umount /dev/$MDEV

			[ -L /media/hdd ] && [ $(readlink /media/hdd) == $MOUNTPOINT/movie ] && rm /media/hdd && rm /media/.moviedev
			[ -L /var/backup ] && [ $(readlink /var/backup) == $MOUNTPOINT/backup ] && rm /var/backup && rm /media/.backupdev
			[ -L /var/swapextensions ] && [ $(readlink /var/swap) == $MOUNTPOINT/swapextensions ] && rm /var/swapextensions && rm /media/.swapextensionsdev
			#echo "[mdev-mount.sh] umounted $MOUNTPOINT" >> $LOG
		fi
		;;
	*)
		# Unexpected keyword
		exit 1
		;;
esac

notify

