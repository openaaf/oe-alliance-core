DESCRIPTION = "RarFs is a virtual filesystem to mount an rar archives"
MAINTAINER = "TitanNit Developer"
LICENSE = "GPLv2"
require conf/license/license-gplv2.inc

DEPENDS = " \
	fuse \
	"

inherit gitpkgv

SRCREV = "${AUTOREV}"
PV = "${IMAGE_VERSION}+git"
PKGV = "${IMAGE_VERSION}+git${GITPKGV}"

SRC_URI = "git://github.com/vadmium/rarfs.git;protocol=https;branch=master"

#S = "${UNPACKDIR}/git"

inherit autotools pkgconfig

#FILES:${PN} = "/usr/bin"
#FILES:${PN} += "/usr/share/gmediarender"
