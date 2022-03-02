SUMMARY = "Itsy Package Management System library"
SECTION = "base"
LICENSE = "GPLv2"
require conf/license/license-gplv2.inc

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit autotools pkgconfig

SRCREV = "${AUTOREV}"
PV = "${SRCPV}"

SRC_URI = "svn://public:public@sbnc.dyndns.tv/svn/titan;module=libipkg;protocol=http"

DEPENDS = "libarchive"
RDEPENDS_${PN} = "libarchive"

S = "${WORKDIR}/libipkg"

