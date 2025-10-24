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
SRC_URI = "svn://svn.dyndns.tv/svn/tools;module=portscan;protocol=http;user=public;pswd=public;externals=allowed"

S = "${WORKDIR}/portscan"

do_compile() {
	cd ${S}
	${CC} portscan.c -O2 -lpthread ${LDFLAGS} -o portscan -Wall -Wno-unused-but-set-variable -Wno-implicit-function-declaration -Wno-unused-variable -Wno-format-overflow -Wno-format-truncation -Wno-nonnull -Wno-restrict -Wno-int-conversion -Wno-return-mismatch -Wno-implicit-int
}

FILES:${PN} = "/sbin"

do_install() {
	install -d ${D}/sbin
	install -m 0755 portscan ${D}/sbin/portscan
}
do_install[vardepsexclude] += "DATETIME"
