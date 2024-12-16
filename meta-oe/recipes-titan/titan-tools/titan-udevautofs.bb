PACKAGE_ARCH = "${MACHINEBUILD}"

PR:append = ".1"

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
FILESEXTRAPATHS:prepend := "${THISDIR}/${DISTRO_NAME}:"
FILESEXTRAPATHS:prepend := "${THISDIR}/${MACHINE}:"
FILESEXTRAPATHS:prepend := "${THISDIR}/${MACHINEBUILD}:"

SRC_URI += "file://85-autofs.rules"
SRC_URI += "file://autofs.sh"

hostname = "${MACHINEBUILD}"

do_install:append() {
    install -d ${D}${sysconfdir}/udev
    install -m 0755 ${S}/autofs.sh       ${D}${sysconfdir}/udev
    install -d ${D}${sysconfdir}/udev/rules.d
    install -m 0755 ${S}/85-autofs.rules       ${D}${sysconfdir}/udev/rules.d
}

