PACKAGE_ARCH = "${MACHINEBUILD}"

require conf/license/license-gplv2.inc
inherit cmake

SUMMARY = "OScam ${PV} Open Source Softcam"
LICENSE = "GPLv3"
LIC_FILES_CHKSUM = "file://COPYING;md5=d32239bcb673463ab874e80d47fae504"

SRCREV = "${AUTOREV}"
SRC_URI = "svn://public:public@sbnc.dyndns.tv/svn/ipk/source.arm;module=emus_oscam;protocol=http"
SRCREV_FORMAT = "${PV}"

SRC_URI += "svn://svn.streamboard.tv/oscam;protocol=https;module=trunk;scmdata=keep;externals=nowarn"

E = "${WORKDIR}/emus_oscam"

DEPENDS = "libusb openssl"

S = "${WORKDIR}/trunk"

EXTRA_OECMAKE_append_arm += " -DOSCAM_SYSTEM_NAME=FriendlyARM"
EXTRA_OECMAKE_append_mipsel += " -DOSCAM_SYSTEM_NAME=FriendlyMIPSEL"
EXTRA_OECMAKE_append_sh4 += " -DOSCAM_SYSTEM_NAME=FriendlySH4"

EXTRA_OECMAKE += "\
    -DWEBIF=1 \
    -DWITH_STAPI=0 \
    -DHAVE_LIBUSB=1 \
    -DSTATIC_LIBUSB=1 \
    -DWITH_SSL=1 \
    -DCLOCKFIX=0 \
    -DMODULE_CONSTCW=1 \
    -DHAVE_PCSC=0"

#CFLAGS_append_arm = " -DOSCAM_SYSTEM_NAME=FriendlyARM"
#CFLAGS_append_mipsel = " -DOSCAM_SYSTEM_NAME=FriendlyMIPSEL"
#CFLAGS_append_sh4 = " -DOSCAM_SYSTEM_NAME=FriendlySH4"

do_install() {
    install -d ${D}/bin
    install -m 0755 ${WORKDIR}/build/oscam ${D}/bin/oscam
    cd ${E}
    cp -a _path_/keys ${D}/
    cp -a _path_/etc ${D}/

#echo ${WORKDIR}/trunk
#ls -al ${WORKDIR}/trunk
    SVNVERSION=$(svnversion ${WORKDIR}/trunk)
    sed "s/Description:.*/Description: Latest Version $SVNVERSION of OScam/" -i ${E}/CONTROL/control
#    sed "s!_path_!/mnt/swapextensions!g" -i ${D}/*/oscam.*
#    sed "s!_type_!MNT!g" -i ${D}/*/oscam.*
#    sed "s!_path_!/mnt/swapextensions!g" -i ${E}/CONTROL/postinst

#    sed 's!$1!/mnt/swapextensions!g' -i ${E}/CONTROL/postinst

#    POSTINST=$(cat ${E}/CONTROL/postinst)
#echo POSTINST $POSTINST

}

do_configure2_prepend(){
	find ${S}/ -type f -name "struct.h" | xargs -r -L1 sed -i "s|@VISIONVERSION@|${VISIONVERSION}|g"
	find ${S}/ -type f -name "struct.h" | xargs -r -L1 sed -i "s|@VISIONREVISION@|${VISIONREVISION}|g"
	find ${S}/ -type f -name "struct.mipsel.h" | xargs -r -L1 sed -i "s|@VISIONVERSION@|${VISIONVERSION}|g"
	find ${S}/ -type f -name "struct.mipsel.h" | xargs -r -L1 sed -i "s|@VISIONREVISION@|${VISIONREVISION}|g"
	find ${S}/ -type f -name "security.h" | xargs -r -L1 sed -i "s|@MACHINE@|${MACHINE}|g"
	find ${S}/ -type f -name "security.h" | xargs -r -L1 sed -i "s|@BOX_BRAND@|${BOX_BRAND}|g"
	find ${S}/ -type f -name "security.h" | xargs -r -L1 sed -i "s|@SOC_FAMILY@|${SOC_FAMILY}|g"
	find ${S}/ -type f -name "security.h" | xargs -r -L1 sed -i "s|@STB_PLATFORM@|${STB_PLATFORM}|g"
}

FILES_${PN} = "/bin /etc /keys"
INSANE_SKIP_${PN} = "already-stripped"

python populate_packages_prepend() {
    def getControlLines(mydir, d, package):
        packagename = package[-1]

        import os

        try:
            print("package1 ", package)
            if(len(package) != 4):
                print("5 return")                
                return
            section = package[2]

            path = mydir + "/CONTROL/control"
            print("path ", path)

            src = open(path).read()
            print("src ", src)
        except IOError:
            return

        for line in src.split("\n"):
            rev = bb.data.expand('${SRCPV}', d)
            box = bb.data.expand('${MACHINEBUILD}', d)
            pr = bb.data.expand('${PR}', d)
            workdir = bb.data.expand('${WORKDIR}', d)

            full_package = package[0] + '-' + package[1] + '-' + package[2] + '-' + package[3]
            print("full_package ", full_package)

            pic = package[0] + '-' + package[1] + '-' + package[2] + '-' + package[3] + '_' + rev + '-' + pr + '_' + box + '.png'
            print("pic ", pic)

            cmd = 'ls -al ' + mydir + '/preview/prev.png'
            print("cmd1 ", cmd)
            print(" ")
            os.system(cmd)

            cmd = 'mkdir -p ' + workdir + '/deploy-png/' + box + '/preview/'
            print("cmd2 ", cmd)
            print(" ")
            os.system(cmd)

            cmd = 'cp -a ' + mydir + '/preview/prev.png ' + workdir + '/deploy-png/' + box + '/' + pic
            print("cmd3 ", cmd)
            print(" ")
            os.system(cmd)

            if line.startswith('Description: '):
                print("found decription ", line[13:])
                d.setVar('DESCRIPTION_' + full_package, line[13:])
                d.setVar('SUMMARY_' + full_package, line[13:])
            elif line.startswith('Showname: '):
                print("found showname ", line[10:])
                d.setVar('SHOWNAME_' + full_package, line[10:])
            elif line.startswith('Maintainer: '):
                d.setVar('MAINTAINER_' + full_package, line[12:])

            postinstfile = mydir + "/CONTROL/postinst"
            postinst = open(postinstfile).read()
            print("postinst ", postinst)

            d.setVar('pkg_postinst_' + full_package, postinst)

    mydir = bb.data.expand('${E}', d)
    print("mydir ", mydir)

    for package in d.getVar('PACKAGES', d, 1).split():
        getControlLines(mydir, d, package.split('-'))
}

do_package_qa() {
}

do_package_write_ipk_append() {
    bb.process.run("cp -a ../deploy-png/* .")
}

pkg_preinst1_${PN}() {
}

pkg_preinst2_${PN}() {
}

pkg_postinst3_${PN}() {
#!/bin/sh

echo pwd `pwd`

echo CURDIR $(CURDIR)

echo 1 $1

echo * $*

exit 0

}

pkg_postrm1_${PN}() {
}
