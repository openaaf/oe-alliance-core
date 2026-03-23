DESCRIPTION = "xupnpd - eXtensible UPnP agent"
HOMEPAGE = "http://xupnpd.org"

MAINTAINER = "TitanNit Developer"
LICENSE = "GPLv2"
require conf/license/license-gplv2.inc

DEPENDS = " \
	libusb-compat \
	"

inherit gitpkgv

SRCREV = "${AUTOREV}"
PV = "${IMAGE_VERSION}+git"
PKGV = "${IMAGE_VERSION}+git${GITPKGV}"

SRC_URI = "git://github.com/Duckbox-Developers/dpf-ax.git;protocol=https;branch=dreamlayers \
			file://libdpf-crossbuild.patch \
		  "
#			file://libdpf-crossbuild.patch

S = "${UNPACKDIR}/titan-libdpf-${PV}/dpflib"

#SRC     = "main.cpp soap.cpp mem.cpp mcast.cpp luaxlib.cpp luaxcore.cpp luajson.cpp luajson_parser.cpp"
#LUAMYCFLAGS = "-DLUA_USE_LINUX"
#LUA = "lua-5.3.5"
##LUA = "lua-5.1.4"
#CFLAGS:append = " -DLUA_USE_LINUX -fno-exceptions -fno-rtti -O2 -I${LUA} -L${LUA}"
#LDFLAGS:prepend = " -llua -lm -ldl -lssl -lcrypto "

CFLAGS:append = " \
	-I${STAGING_DIR_TARGET}/usr \
	-I${STAGING_DIR_TARGET}/usr/include \
	-I${STAGING_DIR_TARGET}/usr/include/freetype2 \
	-I${STAGING_DIR_TARGET}/usr/include/libpng16 \
	"
do_configure:prepend() {
#	cd ${S}
}

SOURCE_FILES = "dpflib.c"

do_compile() {
	cd ${S}
	make

#	mkdir -p $(TARGET_INCLUDE_DIR)/libdpf; \
#	cp dpf.h $(TARGET_INCLUDE_DIR)/libdpf/libdpf.h; \
#	cp ../include/spiflash.h $(TARGET_INCLUDE_DIR)/libdpf/; \
#	cp ../include/usbuser.h $(TARGET_INCLUDE_DIR)/libdpf/; \
#	cp libdpf.a $(TARGET_LIB_DIR)/
}

do_install() {
}

