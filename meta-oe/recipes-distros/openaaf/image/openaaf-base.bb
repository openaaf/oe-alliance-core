SUMMARY = "Base packages require for image."
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302 \
                    file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

ALLOW_EMPTY_${PN} = "1"

PV = "1.0"
PR = "r37"

inherit packagegroup

PACKAGE_ARCH = "${MACHINE_ARCH}"

DEPENDS = " \
	ca-certificates \
	flip \
	hddtemp \
	openatv-enigma2 \
	openatv-spinner \
	oe-alliance-base \
    ${PYTHON_PN}-pillow \
    ${PYTHON_PN}-service-identity \
    ${PYTHON_PN}-requests \
    ${PYTHON_PN}-future \
    ${PYTHON_PN}-pexpect \
    ${PYTHON_PN}-six \
    rtmpdump \
    zip \
    ${@bb.utils.contains("TUNE_FEATURES", "armv", "glibc-compat", "", d)} \
    ofgwrite \
    titan-base \
	\
	openatv-feeds \
	oe-alliance-base-nogui \
	oe-alliance-base-small \
	oe-alliance-branding \
	oe-alliance-branding-remote \
	oe-alliance-drivers \
	oe-alliance-enigma2 \
	oe-alliance-enigma2-small \
	oe-alliance-feeds \
	oe-alliance-picon-feed \
	oe-alliance-remote \
	oe-alliance-skins \	
	"
#openatv tasks 19573
#openaaf tasks 19861
#openaaf tasks 20644

TITANPACKAGES += "\
	titan-autorestore \
	titan-fbread \
 	titan-infobox \
	titan-rarfs \
	titan-tuxtxt \
	titan-portscan \
	titan-bouquet2m3u \
	"

TITANGUI += "\
   	titan \
	titan-plugin-tools-filemanager \
	titan-plugin-infos-imdbapi \
	titan-plugin-infos-imdb \
	titan-plugin-player-mc \
	titan-plugin-network-networkbrowser \
	titan-plugin-tools-readerconfig \
	titan-plugin-infos-streaminfo \
	titan-plugin-player-tithek \
	titan-plugin-infos-tmdb \
	titan-plugin-infos-weather \
	titan-plugin-skins-default \
    titan-plugin-settings-default.all \
	"

RDEPENDS:${PN} = "\
	aio-grab \
	alsa-conf \
	alsa-utils \
	autofs \
    avahi-daemon \
	bash \
	curl \
	dropbear \
	e2fsprogs-mke2fs \
	early-configure \
	ethtool \
	fuse-exfat \
	glibc-gconv-iso8859-15 \
	glib-networking \
	jpeg-tools \
	kernel-module-ftdi-sio \
	kernel-module-pl2303 \
	kernel-module-belkin-sa \
	kernel-module-keyspan \
	libdreamdvd \
	libdvdcss \
	module-init-tools-depmod \
	modutils-loadscript \
	ofgwrite \
    openssh-sftp-server \
	openssl \
	opkg \
	packagegroup-base \
	packagegroup-core-boot \
	parted \
	pngquant \
	procps \
	rtmpdump \
	openaaf-bootlogo \
	tuxtxt-enigma2 \
	util-linux-blkid \
	util-linux-sfdisk \
	util-linux-fsck \
	volatile-media \
	wget \
	\
	\	
	${@bb.utils.contains("TARGET_ARCH", "sh4", "alsa-utils-amixer-conf" , "", d)} \
	openaaf-version-info \
    enigma2-dhcp-wait \
    enigma-info \
	\
    \
    oe-alliance-feeds-configs \
    oe-alliance-botfeed-configs \
    ${@bb.utils.contains("MACHINE_FEATURES", "wol", "vuplus-coldboot vuplus-ethwol", "", d)} \
    ${@bb.utils.contains("MACHINE_FEATURES", "wowl", "vuplus-wowl", "", d)} \
    ${@bb.utils.contains("MACHINE_FEATURES", "iniwol", "ini-coldboot ini-ethwol", "", d)} \
    ${@bb.utils.contains("MACHINE_FEATURES", "gbwol", "gigablue-ethwol", "", d)} \
    ${@bb.utils.contains("MACHINE_FEATURES", "gbsoftwol", "gigablue-ethsoftwol", "", d)} \
    ${@bb.utils.contains("MACHINE_FEATURES", "smallflash", "" , "nmap", d)} \
    ${@bb.utils.contains("MACHINE_FEATURES", "emmc", "dosfstools mtools e2fsprogs-resize2fs partitions-by-name" , "", d)} \
    ${@bb.utils.contains("MACHINE_FEATURES", "fastboot", "dosfstools mtools android-tools" , "", d)} \
    ${@bb.utils.contains("MACHINE_FEATURES", "recovery", "recovery" , "", d)} \
    ${@bb.utils.contains("MACHINE_FEATURES", "kexecmb", "kexec-multiboot", "", d)} \
    ${@bb.utils.contains("MACHINE_FEATURES", "displayvfd", "displayvfd", "", d)} \
    ${@bb.utils.contains("TARGET_ARCH", "arm", "${GETEXTRA}", "", d)} \
    ${@bb.utils.contains("TARGET_ARCH", "aarch64", "${GETEXTRA}", "", d)} \
	\
	${TITANPACKAGES} \
	\
    oe-alliance-picon-feed \
    ${@bb.utils.contains("MACHINE_FEATURES", "nogui", "", "${NORMAL_GUI}", d)} \
    ${@bb.utils.contains("SMALLBOXWIZARD", "1", "${SMALLBOXWIZARD_IMAGE}", "${NORMAL_IMAGE}", d)} \
"
 
SMALLBOXWIZARD_IMAGE = "\
     ${@bb.utils.contains_any("MACHINE_FEATURES", "smallflash", "", "${NORMAL_IMAGE}", d)} \
"

NORMAL_IMAGE = "\
	curlftpfs \
	djmount \
    e2fsprogs-e2fsck \
    e2fsprogs-tune2fs \
	exteplayer3 \
	evtest \
	libavahi-client \
	libusb1 \
	nfs-utils \
	nfs-utils-client \
	ntfs-3g \
	mc \
    minilocale \
    mtd-utils \
    mtd-utils-ubifs \
	oe-alliance-wifi \
	packagegroup-base-smbfs-client \
	packagegroup-base-smbfs-server \
   	packagegroup-base-smbfs-utils \
   	packagegroup-base-nfs \
	samba \
    sdparm \
	smbclient \
	smbnetfs \
    tzdata \
    vsftpd \
	wakelan \
	wireless-tools \
	wpa-supplicant \
	${@bb.utils.contains('TUNE_FEATURES', 'aarch64', 'lib32-webkit-hbbtv-plugin' , 'webkit-hbbtv-plugin', d)} \
"
#	${@bb.utils.contains('MACHINE', 'dm900', 'webkit-hbbtv-plugin' , '', d)}

NORMAL_GUI = "\
	${TITANGUI} \
"

# The following RRECOMMENDS ensure that images on boxes with very limited
# kernel space behave identical to those that have these options built-in
# by including the corresponding kernel modules.
# So far these are xfs and vfat and their dependencies
RRECOMMENDS:${PN} = "\
    kernel-module-xfs \
    kernel-module-exportfs \
    kernel-module-fat \
    kernel-module-msdos \
    kernel-module-vfat \
    kernel-module-nls-cp437 \
    kernel-module-nls-iso8859-1 \
    kernel-module-nls-iso8859-15 \
    "

GETEXTRA = "edid-decode"

