DESCRIPTION = "xupnpd - eXtensible UPnP agent"
HOMEPAGE = "http://xupnpd.org"

MAINTAINER = "TitanNit Developer"
LICENSE = "GPLv2"
require conf/license/license-gplv2.inc

DEPENDS = " \
	dbus \
	glibc \
	libusb-compat \
 	ncurses \
	sqlite3 \
	\
	libgd  \
	\
	libusb-compat \
    libusb \
    titan-libdpf \
	"

inherit autotools pkgconfig gitpkgv

PACKAGES = "${PN}"

SRCREV = "${AUTOREV}"
PV = "${IMAGE_VERSION}+git"
PKGV = "${IMAGE_VERSION}+git${GITPKGV}"

SRC_URI = "git://github.com/MaxWiesel/lcd4linux-max;protocol=https;branch=master"
SRC_URI += "file://lcd4linux"
SRC_URI += "file://lcd4linux.conf"

S = "${UNPACKDIR}/titan-lcd4linux-${PV}"

CFLAGS:append = " -Wno-incompatible-pointer-types -std=gnu17"

#CFLAGS:append:arm:vuplussss = " VUPLUS4K"

do_compile() {
	cd ${S}

	./bootstrap
	#LCD4LINUX_EXTRA_DRIVER = VUPLUS4K
	#./configure --host=${HOST_SYS} --build=${BUILD_SYS} --with-drivers='DPF,SamsungSPF,PNG,$(LCD4LINUX_EXTRA_DRIVER)' --with-plugins='all,!apm,!asterisk,!dbus,!dvb,!gps,!hddtemp,!huawei,!imon,!isdn,!kvv,!mpd,!mpris_dbus,!mysql,!pop3,!ppp,!python,!qnaplog,!raspi,!sample,!seti,!w1retap,!wireless,!xmms' --without-ncurses
	./configure --host=${HOST_SYS} --build=${BUILD_SYS} --with-drivers='DPF,SamsungSPF,PNG' --with-plugins='all,!apm,!asterisk,!dbus,!dvb,!gps,!hddtemp,!huawei,!imon,!isdn,!kvv,!mpd,!mpris_dbus,!mysql,!pop3,!ppp,!python,!qnaplog,!raspi,!sample,!seti,!w1retap,!wireless,!xmms' --without-ncurses

	#make vcs_version all CC=${CC} CFLAGS='${CFLAGS}' LD='${CC} ${LDFLAGS}';
	make vcs_version all CFLAGS='${CFLAGS}';

   ${STRIP} lcd4linux
}

FILES:${PN} = " \
    /etc/init.d \
	/usr/bin \
"

do_install() {
	install -d ${D}/usr/bin ${D}/etc/init.d
	cp ${S}/lcd4linux ${D}/usr/bin/
    install -d ${D}${sysconfdir}
    install -m 0755 ${UNPACKDIR}/lcd4linux.conf       ${D}${sysconfdir}
    install -d ${D}${sysconfdir}/init.d
    install -m 0755 ${UNPACKDIR}/lcd4linux       ${D}${sysconfdir}/init.d
}

FILES:${PN} += "${sysconfdir}/lcd4linux.conf ${sysconfdir}/etc/init.d/lcd4linux"

