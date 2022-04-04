SUMMARY = "Plugins for Titan"
MAINTAINER = "TitanNit Team"
SECTION = "plugins"
#PRIORITY = "optional"
LICENSE = "GPLv2"
PACKAGE_ARCH = "${MACHINE_ARCH}"
PACKAGES_DYNAMIC = "titan-plugin-(?!oea-).*"

require conf/license/license-gplv2.inc

SRCREV = "${AUTOREV}"
PV = "${SRCPV}"

SRC_URI = "svn://buildbin:buildbin@sbnc.dyndns.tv;module=svn;protocol=http"

DEPENDS = "titan \
	python-pyopenssl \
	python-gdata \
	streamripper \
	python-mutagen \
	python-twisted \
	python-daap \
	python-google-api-client \
	python-httplib2 \
	python-youtube-dl \
	libtirpc \
	"

RDEPENDS_${PN} = "python-ctypes"

S = "${WORKDIR}/svn/titan/plugins"

#inherit autotools-brokensep pkgconfig
#inherit autotools-brokensep
inherit autotools-brokensep gitpkgv pythonnative pkgconfig gettext

CFLAGS = "\
	-I${STAGING_DIR_TARGET}/usr/include \
	-I${STAGING_DIR_TARGET}/usr/include/curl \
	-I${STAGING_DIR_TARGET}/usr/include/python2.7 \
	-include Python.h \
	-I${STAGING_DIR_TARGET}/usr/include/tirpc \
	-I${STAGING_DIR_TARGET}/usr/include \
	-I${STAGING_DIR_TARGET}/usr/include/freetype2 \
	-I${STAGING_DIR_TARGET}/usr/include/openssl \
	-I${STAGING_DIR_TARGET}/usr/include/dreamdvd \
	-I${STAGING_DIR_TARGET}/usr/include/libdreamdvd \
	-I${WORKDIR}/svn/titan/libdreamdvd \
	-I${WORKDIR}/svn/titan/titan \
	-I${WORKDIR}/svn/titan/titan/include \
	-I${WORKDIR}/svn/titan/libeplayer3/include"

CFLAGS_append_sh4 = " \
	-I${STAGING_DIR_TARGET}/usr/include/libmmeimage \
	-I${STAGING_KERNEL_DIR}/extra/bpamem \
	"

CFLAGS_append_sh4 = " -DOEBUILD -DEXTEPLAYER3 -DEPLAYER3 -DSH4 -DSH4NEW -DCAMSUPP -Os -export-dynamic -Wall -Wno-unused-but-set-variable -Wno-implicit-function-declaration"
CFLAGS_append_mipsel = " -DOEBUILD -DEXTEPLAYER3 -DEPLAYER3 -DCAMSUPP -Os -mhard-float -export-dynamic -Wall -Wno-unused-but-set-variable -Wno-implicit-function-declaration -Wno-unused-variable -Wno-format-overflow -Wno-format-truncation -Wno-nonnull -Wno-restrict"
CFLAGS_append_arm = " -DOEBUILD -DEXTEPLAYER3 -DEPLAYER3 -DCAMSUPP -Os -mhard-float -export-dynamic -Wall -Wno-unused-but-set-variable -Wno-implicit-function-declaration -Wno-unused-variable -Wno-format-overflow -Wno-format-truncation -Wno-nonnull -Wno-restrict"

LDFLAGS_prepend = " -lcurl "

do_configure() {
    cd ${S}

    SVNVERSION=${SRCPV}
	echo SVNVERSION: ${SVNVERSION}

	sed "s/^#define PLUGINVERSION .*/#define PLUGINVERSION $SVNVERSION/" -i  ../titan/struct.h
	cat ../titan/struct.h | grep "define PLUGINVERSION"

	libtoolize --force
	aclocal -I ${STAGING_DIR_TARGET}/usr/share/aclocal
	autoconf
	automake --foreign --add-missing
	./configure --host=${HOST_SYS} --build=${BUILD_SYS}
}

do_compile() {
	cd ${S}
	make clean
	make -f Makefile
	${STRIP} ${S}/*/*/.libs/*.so
}

FILES_${PN} = "/usr/local/share/titan/plugins"

do_install() {
	install -d ${D}/usr/local/share/titan/plugins
	
	SECTIONLIST="`cat ../plugins/Makefile.am | sed 's/\\t\+/ /g' | sed 's/ \\+//g' | sed 's/\\\//g' | grep -v =`"
	echo SECTIONLIST $SECTIONLIST
	for SECTION in $SECTIONLIST;do
		echo SECTION $SECTION
    	PLUGINLIST="`cat ../plugins/$SECTION/Makefile.am | sed 's/\\t\+/ /g' | sed 's/ \\+//g' | sed 's/\\\//g' | grep -v =`"

	    for PLUGIN in $PLUGINLIST;do
		    echo PLUGIN $PLUGIN
		    install -d ${D}/usr/local/share/titan/plugins/$SECTION/$PLUGIN
		    install -m 0644 ../plugins/$SECTION/$PLUGIN/.libs/*.so ${D}/usr/local/share/titan/plugins/$SECTION/$PLUGIN/

		    if test -e ../plugins/$SECTION/$PLUGIN/$NAME.sh;then
			    install -m 0655 ../plugins/$SECTION/$PLUGIN/*.sh ${D}/usr/local/share/titan/plugins/$SECTION/$PLUGIN
		    fi
		    if test -e ../plugins/$SECTION/$PLUGIN/files;then
			    cp -a ../plugins/$SECTION/$PLUGIN/files ${D}/usr/local/share/titan/plugins/$SECTION/$PLUGIN/
		    fi
		    if test -e ../plugins/$SECTION/$PLUGIN/picons;then
			    cp -a ../plugins/$SECTION/$PLUGIN/picons ${D}/usr/local/share/titan/plugins/$SECTION/$PLUGIN/
		    fi
		    if test -e ../plugins/$SECTION/$PLUGIN/skin;then
			    cp -a ../plugins/$SECTION/$PLUGIN/skin ${D}/usr/local/share/titan/plugins/$SECTION/$PLUGIN/
		    fi
		    if test -e ../plugins/$SECTION/$PLUGIN/skin.xml;then
			    install -m 0644 ../plugins/$SECTION/$PLUGIN/skin.xml ${D}/usr/local/share/titan/plugins/$SECTION/$PLUGIN/
		    fi
		    if test -e ../plugins/$SECTION/$PLUGIN/plugin.png;then
			    install -m 0644 ../plugins/$SECTION/$PLUGIN/plugin.png ${D}/usr/local/share/titan/plugins/$SECTION/$PLUGIN/
		    fi
		    if test -e ../plugins/$SECTION/$PLUGIN/default.jpg;then
			    install -m 0644 ../plugins/$SECTION/$PLUGIN/default.jpg ${D}/usr/local/share/titan/plugins/$SECTION/$PLUGIN/
		    fi
	    done
	done
}

python populate_packages_prepend() {
    titan_plugindir = bb.data.expand('/usr/local/share/titan/plugins', d)
    do_split_packages(d, titan_plugindir, '(.*?/.*?)/.*', 'titan-plugin-%s', '%s', recursive=True, match_path=True, prepend=True, extra_depends="titan")

    def getControlLines(mydir, d, package):
        packagename = package[-1]

        import os
        try:
            print("package1 ", package)
            if(len(package) != 4):
                print("5 return")                
                return
            section = package[2]
            src = open(mydir + section + "/" + packagename + "/CONTROL/control").read()
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

            cmd = 'ls -al ' + mydir + section + '/' + packagename + '/preview/prev.png'
            print("cmd1 ", cmd)
            print(" ")
            os.system(cmd)

            cmd = 'mkdir -p ' + workdir + '/deploy-png/' + box + '/preview/'
            print("cmd2 ", cmd)
            print(" ")
            os.system(cmd)

            cmd = 'cp -a ' + mydir + section + '/' + packagename + '/preview/prev.png ' + workdir + '/deploy-png/' + box + '/' + pic
            print("cmd3 ", cmd)
            print(" ")
            os.system(cmd)

#            cmd = 'cp -a ' + mydir + section + '/' + packagename + '/preview/prev.png ' + workdir + '/deploy-png/' + box + '/preview/titan-pluginpreview-' + packagename + '.png'
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

    mydir = d.getVar('D', True) + "/../svn/titan/plugins/"
    print("1mydir ", mydir)
    for package in d.getVar('PACKAGES', d, 1).split():
        getControlLines(mydir, d, package.split('-'))
}

do_package_qa() {
}

do_package_write_ipk_append() {
    bb.process.run("cp -a ../deploy-png/* .")
#    bb.process.run("cp -a ../preview .")
}


