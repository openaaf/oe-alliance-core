SUMMARY = "Base packages require for image."
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302 \
                    file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

ALLOW_EMPTY_${PN} = "1"

PV = "1.0"
PR = "r16"

inherit packagegroup

DEPENDS = " \
	ca-certificates \
	flip \
	hddtemp \
	openatv-enigma2 \
	openatv-spinner \
	oe-alliance-base \
    ${PYTHON_PN}-service-identity \
    ${PYTHON_PN}-requests \
    ${PYTHON_PN}-future \
    ${PYTHON_PN}-pexpect \
    ${PYTHON_PN}-six \
	rtmpdump \
	titan-gmediarender \
	${@bb.utils.contains('MACHINE', 'dm900', 'webkit-hbbtv-plugin' , '', d)} \
	oe-alliance-feeds \
	"

#	titan-netsurf

RDEPENDS:${PN} = "\
	aio-grab \
	alsa-conf \
	alsa-utils \
	autofs \
	avahi-daemon \
	bash \
	curl \
	curlftpfs \
	djmount \
	dropbear \
	e2fsprogs-e2fsck \
	e2fsprogs-mke2fs \
	e2fsprogs-tune2fs \
	early-configure \
	ethtool \
	exteplayer3 \
	evtest \
	fuse-exfat \
	glibc-gconv-iso8859-15 \
	glib-networking \
	jpeg-tools \
	kernel-module-ftdi-sio \
	kernel-module-pl2303 \
	kernel-module-belkin-sa \
	kernel-module-keyspan \
	kernel-module-tun \
	libdreamdvd \
	libdvdcss \
	libusb1 \
	mc \
	minilocale \
	module-init-tools-depmod \
	modutils-loadscript \
	mtd-utils \
	nfs-utils \
	nfs-utils-client \
	ntfs-3g \
	ntpdate \
	ofgwrite \
    openssh-sftp-server \
	openssl \
	opkg \
	packagegroup-base \
	packagegroup-core-boot \
	packagegroup-base-smbfs-client \
	packagegroup-base-smbfs-server \
   	packagegroup-base-smbfs-utils \
   	packagegroup-base-nfs \
	parted \
	${@bb.utils.contains('MACHINE_FEATURES', 'emmc', 'partitions-by-name' , '', d)} \ 
	pngquant \
	procps \
	rtmpdump \
	samba \
	sdparm \
	smbclient \
	smbnetfs \
	openaaf-bootlogo \
	titan-rarfs \
	tuxtxt-enigma2 \
	tzdata tzdata-europe tzdata-australia tzdata-asia tzdata-pacific tzdata-africa tzdata-americas \
	util-linux-blkid \
	util-linux-sfdisk \
	util-linux-fsck \
	volatile-media \
	vsftpd \
	wakelan \
	wget \
	wireless-tools \
	wpa-supplicant \
	\
	\	
	${@oe.utils.conditional('MACHINE', 'dm800', '', 'mtd-utils-ubifs', d)} \
	${@bb.utils.contains("MACHINE_FEATURES", "dvbc-only", "", "", d)} \
	${@bb.utils.contains("MACHINE_FEATURES", "iniwol", "ini-coldboot ini-ethwol", "", d)} \
	${@bb.utils.contains("MACHINE_FEATURES", "libpassthrough", "libpassthrough libdlsym", "", d)} \
	${@bb.utils.contains("MACHINE_FEATURES", "no-nmap", "" , "nmap", d)} \
	${@bb.utils.contains("MACHINE_FEATURES", "singlecore", "", \
	" \
	", d)} \
	${@bb.utils.contains("TARGET_ARCH", "sh4", "alsa-utils-amixer-conf" , "", d)} \
	oe-alliance-feeds-configs \
	openatv-version-info \
	\
	titan-autorestore \
 	titan-infobox \
	titan-rarfs \
	titan-fbread \
	titan-tuxtxt \
	${@bb.utils.contains("MACHINE_FEATURES", "smallflash", "", "enigma2-plugin-extensions-enhancedmoviecenter", d)} \
	${@bb.utils.contains("MACHINE_FEATURES", "dreamboxv1", "enigma2-plugin-extensions-dflash mtd-utils-jffs2", "", d)} \
	${@bb.utils.contains("MACHINE_FEATURES", "dreamboxv2", "enigma2-plugin-extensions-dbackup e2fsprogs-badblocks", "", d)} \
	${@bb.utils.contains("MACHINE_FEATURES", "boxmodel", "boxmodel", "", d)} \
	${@bb.utils.contains("MACHINE_FEATURES", "uianimation", "enigma2-plugin-systemplugins-animationsetup" , "", d)} \
	${@bb.utils.contains("MACHINE_FEATURES", "osdanimation", "enigma2-plugin-systemplugins-animationsetup" , "", d)} \
	${@bb.utils.contains("MACHINE_FEATURES", "webkithbbtv", "enigma2-plugin-extensions-webkithbbtv", "", d)} \
	${@bb.utils.contains("MACHINE_FEATURES", "grautec", "enigma2-plugin-extensions-grautec", "", d)} \
	${@bb.utils.contains("MACHINE_FEATURES", "chromiumos", "enigma2-plugin-extensions-chromium", "", d)} \
   	titan \
   	titan-plugins \
	titan-plugin-filemanager \
	titan-plugin-imdbapi \
	titan-plugin-imdb \
	titan-plugin-mc \
	titan-plugin-networkbrowser \
	titan-plugin-readerconfig \
	titan-plugin-streaminfo \
	titan-plugin-tithek \
	titan-plugin-tmdb \
	titan-plugin-weather \
	${@bb.utils.contains("MACHINE_FEATURES", "dreamboxv1", "", "oe-alliance-wifi", d)} \
 	"

