SUMMARY = "Skins for Titan"
MAINTAINER = "TitanNit Team"
SECTION = "skins"
#PRIORITY = "optional"
LICENSE = "GPLv2"
PACKAGE_ARCH = "${MACHINE_ARCH}"

require conf/license/license-gplv2.inc

SRCREV = "${AUTOREV}"
PV = "${SRCPV}"

SRC_URI = "svn://buildbin:buildbin@sbnc.dyndns.tv/svn/titan;module=skins;protocol=http"

S = "${WORKDIR}/skins"

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
    do_split_packages(d, titan_skindir, '(.*?)/.*', 'titan-plugin-skins-%s', 'Titan Skin: %s', recursive=True, match_path=True, prepend=True, extra_depends="")
    def getControlLines(mydir, d, package):
        packagename = package[-1]

        import os
        try:
            print("package1 ", package)
            if(len(package) != 4):
                print("5 return")                
                return
            section = package[2]
            src = open(mydir + "/" + packagename + "/CONTROL/control").read()
        except IOError:
            return
        for line in src.split("\n"):
            rev = bb.data.expand('${SRCPV}', d)
            box = bb.data.expand('${MACHINEBUILD}', d)
            pr = bb.data.expand('${PR}', d)
            workdir = bb.data.expand('${WORKDIR}', d)

            full_package = package[0] + '-' + package[1] + '-' + package[2] + '-' + package[3]
            pic = package[0] + '-' + package[1] + '-' + package[2] + '-' + package[3] + '_' + rev + '-' + pr + '_' + box + '.png'
            print("full_package ", full_package)
            print("pic ", pic)

            cmd = 'ls -al ' + mydir + '/' + packagename + '/preview/prev.png'
            print("cmd1 ", cmd)
            print(" ")
            os.system(cmd)

            cmd = 'mkdir -p ' + workdir + '/deploy-png/' + box + '/preview/'
            print("cmd2 ", cmd)
            print(" ")
            os.system(cmd)

            cmd = 'cp -a ' + mydir + '/' + packagename + '/prev.png ' + workdir + '/deploy-png/' + box + '/' + pic
            print("cmd3 ", cmd)
            print(" ")
            os.system(cmd)

#            cmd = 'cp -a ' + mydir + '/' + packagename + '/prev.png ' + workdir + '/deploy-png/' + box + '/preview/titan-pluginpreview-' + packagename + '.png'
#            print("cmd4 ", cmd)
#            print(" ")
#            os.system(cmd)

            print("package ", package)
            if line.startswith('Description: '):
                print("found decription ", line[13:])
                d.setVar('DESCRIPTION_' + full_package, line[13:])
                d.setVar('SUMMARY_' + full_package, line[13:])
                d.setVar('PIC_' + full_package, full_package)
            elif line.startswith('Showname: '):
                print("found showname ", line[10:])
                d.setVar('SHOWNAME_' + full_package, line[10:])
            elif line.startswith('Maintainer: '):
                d.setVar('MAINTAINER_' + full_package, line[12:])

    mydir = d.getVar('D', True) + "/../skins/"
    print("1mydir ", mydir)
    for package in d.getVar('PACKAGES', d, 1).split():
        getControlLines(mydir, d, package.split('-'))
}

do_package_qa() {
}

do_package_write_ipk_append() {
    bb.process.run("cp -a ../deploy-png/* .")
}

PACKAGES_DYNAMIC = "titan-plugin-skins-*"
