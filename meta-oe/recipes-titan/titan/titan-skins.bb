SUMMARY = "Skins for Titan"
MAINTAINER = "TitanNit Team"
SECTION = "skins"
#PRIORITY = "optional"
LICENSE = "GPLv2"
PACKAGE_ARCH = "${MACHINE_ARCH}"

require conf/license/license-gplv2.inc

SRCREV = "${AUTOREV}"
PV = "${SRCPV}"

SRC_URI = "svn://buildbin:buildbin@sbnc.dyndns.tv;module=svn;protocol=http"

S = "${WORKDIR}/svn/titan/skins"

FILES_${PN} = "/usr/local/share/titan/skin"

do_install() {
    cd ${S}

	install -d ${D}/usr/local/share/titan/skin
	LIST="$(ls -1)"
	echo LIST2 $LIST

	for ROUND in $LIST;do
		echo ROUND $ROUND
		install -d ${D}/usr/local/share/titan/skin/$ROUND
        cp -a $ROUND/* ${D}/usr/local/share/titan/skin/$ROUND
	done
}

python populate_packages_prepend() {
    titan_skindir = bb.data.expand('/usr/local/share/titan/skin', d)
    do_split_packages(d, titan_skindir, '(.*?)/.*', 'titan-skin-%s', 'Titan Skin: %s', recursive=True, match_path=True, prepend=True)
}

PACKAGES_DYNAMIC = "titan-skin-*"
