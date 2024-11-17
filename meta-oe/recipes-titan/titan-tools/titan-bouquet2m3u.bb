SUMMARY = "TitanNit is a fast Linux Framebuffer Gui"
MAINTAINER = "TitanNit Team"
SECTION = "network"
LICENSE = "GPLv2"
PACKAGE_ARCH = "${MACHINE_ARCH}"

require conf/license/license-gplv2.inc

inherit gitpkgv

PREMIRRORS = ""
SRCREV = "${AUTOREV}"
PV = "${@bb.fetch2.get_srcrev(d)}"

SVNDIR = "svn/${PN}"
SRC_URI = "svn://sbnc.dyndns.tv/svn/tools;module=bouquet2m3u;protocol=http;user=public;pswd=public;externals=allowed"

S = "${WORKDIR}/bouquet2m3u"

do_compile() {
	cd ${S}
    if [ ${TARGET_ARCH} != "sh4" ];then
    	${CC} GO_bouquet2m3u.c -O2 -mhard-float ${LDFLAGS} -o bouquet2m3u
    else
    	${CC} GO_bouquet2m3u.c -O2 ${LDFLAGS} -o bouquet2m3u -Wall -Wno-unused-but-set-variable -Wno-implicit-function-declaration -Wno-unused-variable -Wno-format-overflow -Wno-format-truncation -Wno-nonnull -Wno-restrict -Wno-int-conversion -Wno-return-mismatch -Wno-implicit-int
    fi
}

FILES:${PN} = "/sbin"

do_install() {
	install -d ${D}/sbin
	install -m 0755 bouquet2m3u ${D}/sbin/bouquet2m3u
}
do_install[vardepsexclude] += "DATETIME"
