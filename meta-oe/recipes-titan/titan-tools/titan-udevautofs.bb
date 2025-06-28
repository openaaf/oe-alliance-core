SUMMARY = "udev rules for autofs with crypt support"
MAINTAINER = "TitanNit Team"
SECTION = "devices"
LICENSE = "GPLv2"
require conf/license/license-gplv2.inc
#LICENSE = "proprietary"

PV = "${IMAGE_VERSION}"
PR = "${BUILD_VERSION}"
PACKAGE_ARCH = "${MACHINEBUILD}"

SSTATE_SKIP_CREATION = "1"

S = "${WORKDIR}/sources"
UNPACKDIR = "${S}"

PACKAGES = "${PN}"

SRC_URI += "file://85-autofs.rules"
SRC_URI += "file://autofs.sh"

do_install[nostamp] = "1"

do_install:append() {
    install -d ${D}${sysconfdir}/udev
    install -m 0755 ${S}/autofs.sh       ${D}${sysconfdir}/udev
    install -d ${D}${sysconfdir}/udev/rules.d
    install -m 0755 ${S}/85-autofs.rules       ${D}${sysconfdir}/udev/rules.d
}

do_install[vardepsexclude] += "DATE DATETIME"

FILES:${PN} += "${sysconfdir}/udev/autofs.sh ${sysconfdir}/udev/rules.d/85-autofs.rules"
