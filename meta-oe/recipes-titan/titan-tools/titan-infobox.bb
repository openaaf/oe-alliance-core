SUMMARY = "TitanNit is a fast Linux Framebuffer Gui"
MAINTAINER = "TitanNit Team"
SECTION = "multimedia"
LICENSE = "GPLv2"
PACKAGE_ARCH = "${MACHINE_ARCH}"

require conf/license/license-gplv2.inc

inherit gitpkgv

PREMIRRORS = ""
SRCREV = "${AUTOREV}"
PV = "${@bb.fetch2.get_srcrev(d)}"

SVNDIR = "svn/${PN}"
SRC_URI = "svn://svn.dyndns.tv/svn/tools;module=infobox;protocol=http;user=public;pswd=public;externals=allowed"

DEPENDS = " \
	freetype \
	libpng \
	jpeg \
	"

S = "${UNPACKDIR}/infobox"

CFLAGS:append:sh4 = " -DSH4"
CFLAGS:append:mipsel = " -DMIPSEL"
CFLAGS:append:arm = " -DMIPSEL"

CFLAGS:append:arm:sf8008 = " -DEVENT0 -DDOUBLE"
CFLAGS:append:mipsel:vusolo2 = " -DEVENT0 -DDOUBLE"

do_compile() {
	cd ${S}
	if [ ${TARGET_ARCH} = "sh4" ];then
		${CC} -Os -c infobox.c -I${STAGING_DIR_TARGET}/usr/include -I${STAGING_DIR_TARGET}/usr/include/freetype2 ${LDFLAGS} -o infobox.o -export-dynamic -Wall -Wno-unused-but-set-variable -Wno-implicit-function-declaration -Wno-unused-variable -Wno-format-overflow -Wno-format-truncation -Wno-nonnull -Wno-restrict ${CFLAGS} -DUSE_BLIT
		${CC} -Os -c readpng.c ${LDFLAGS} -o readpng.o -I${STAGING_DIR_TARGET}/usr/include -I${STAGING_DIR_TARGET}/usr -export-dynamic -Wall -Wno-unused-but-set-variable -Wno-implicit-function-declaration -Wno-unused-variable -Wno-format-overflow -Wno-format-truncation -Wno-nonnull -Wno-restrict ${CFLAGS}
	else
		${CC} -Os -c infobox.c -I${STAGING_DIR_TARGET}/usr/include -I${STAGING_DIR_TARGET}/usr/include/freetype2 ${LDFLAGS} -o infobox.o -mhard-float -export-dynamic -Wall -Wno-unused-but-set-variable -Wno-implicit-function-declaration -Wno-unused-variable -Wno-format-overflow -Wno-format-truncation -Wno-nonnull -Wno-restrict -Wno-int-conversion -Wno-return-mismatch -Wno-implicit-int ${CFLAGS} -DUSE_BLIT
		${CC} -Os -c readpng.c ${LDFLAGS} -o readpng.o -I${STAGING_DIR_TARGET}/usr/include -I${STAGING_DIR_TARGET}/usr -mhard-float -export-dynamic -Wall -Wno-unused-but-set-variable -Wno-implicit-function-declaration -Wno-unused-variable -Wno-format-overflow -Wno-format-truncation -Wno-nonnull -Wno-restrict -Wno-int-conversion -Wno-return-mismatch -Wno-implicit-int ${CFLAGS}
	fi
	${CC} -Os readpng.o infobox.o -L${STAGING_DIR_TARGET}/usr/lib -ljpeg -lpng -lfreetype -lz ${LDFLAGS} -o infobox
}

FILES:${PN} = "/sbin"
INSANE_SKIP:${PN} = "ldflags"

do_install() {
	install -d ${D}/sbin
	install -m 0755 infobox ${D}/sbin/infobox
}
do_install[vardepsexclude] += "DATETIME"
