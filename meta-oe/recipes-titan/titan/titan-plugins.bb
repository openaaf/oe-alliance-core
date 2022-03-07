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
inherit autotools-brokensep

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
	${STRIP} ${S}/*/.libs/*.so
}

FILES_${PN} = "/usr/local/share/titan/plugins"

PROVIDES += " \
    titan-plugin-extensions-imdb"

do_install() {
	install -d ${D}/usr/local/share/titan/plugins
	
	LIST="`cat ../plugins/Makefile.am | sed 's/\\t\+/ /g' | sed 's/ \\+//g' | sed 's/\\\//g' | grep -v =`"
	echo LIST $LIST
	for ROUND in $LIST;do
		echo ROUND $ROUND
		install -d ${D}/usr/local/share/titan/plugins/$ROUND
		install -m 0644 ../plugins/$ROUND/.libs/*.so ${D}/usr/local/share/titan/plugins/$ROUND

		if test -e ../plugins/$ROUND/$ROUND.sh;then
			install -m 0655 ../plugins/$ROUND/*.sh ${D}/usr/local/share/titan/plugins/$ROUND
		fi
		if test -e ../plugins/$ROUND/files;then
			cp -a ../plugins/$ROUND/files ${D}/usr/local/share/titan/plugins/$ROUND/
		fi
		if test -e ../plugins/$ROUND/picons;then
			cp -a ../plugins/$ROUND/picons ${D}/usr/local/share/titan/plugins/$ROUND/
		fi
		if test -e ../plugins/$ROUND/skin;then
			cp -a ../plugins/$ROUND/skin ${D}/usr/local/share/titan/plugins/$ROUND/
		fi
		if test -e ../plugins/$ROUND/skin.xml;then
			install -m 0644 ../plugins/$ROUND/skin.xml ${D}/usr/local/share/titan/plugins/$ROUND/
		fi
		if test -e ../plugins/$ROUND/plugin.png;then
			install -m 0644 ../plugins/$ROUND/plugin.png ${D}/usr/local/share/titan/plugins/$ROUND/
		fi
		if test -e ../plugins/$ROUND/default.jpg;then
			install -m 0644 ../plugins/$ROUND/default.jpg ${D}/usr/local/share/titan/plugins/$ROUND/
		fi
	done
}

python populate_packages_prepend() {
    titan_plugindir = bb.data.expand('/usr/local/share/titan/plugins', d)
    do_split_packages(d, titan_plugindir, '(.*?_.*?)/.*', 'titan-plugin-%s', '%s', recursive=True, match_path=True, prepend=True, extra_depends="titan")
#    do_split_packages(d, titan_plugindir, '^(\w+)/[a-zA-Z0-9_]+.*$', 'titan-plugin-%s', '%s', recursive=True, match_path=True, prepend=True, extra_depends="titan")
#    do_split_packages(d, titan_plugindir, '^(\w+)/.*\.h$', 'titan-plugin-%s-src', '%s (source files)', recursive=True, match_path=True, prepend=True)
#    do_split_packages(d, titan_plugindir, '^(\w+)/.*\.la$', 'titan-plugin-%s-dev', '%s (development)', recursive=True, match_path=True, prepend=True)
#    do_split_packages(d, titan_plugindir, '^(\w+)/.*\.a$', 'titan-plugin-%s-staticdev', '%s (static development)', recursive=True, match_path=True, prepend=True)
#    do_split_packages(d, titan_plugindir, '^(\w+)/(.*/)?\.debug/.*$', 'titan-plugin-%s-dbg', '%s (debug)', recursive=True, match_path=True, prepend=True)

    def getControlLines(mydir, d, package):
        packagename = package[-1]

        import os
        try:
            #ac3lipsync is renamed since 20091121 to audiosync.. but rename in cvs is not possible without lost of revision history..
            #so the foldername is still ac3lipsync
            if packagename == 'audiosync':
                packagename = 'ac3lipsync'
            print("mydir2 ", mydir)
            print("packagename2 ", packagename)
            src = open(mydir + packagename + "/CONTROL/control").read()
            print("src ", src)
        except IOError:
            return
        for line in src.split("\n"):
            print("full_package1")
            print("package[0] ", package[0])
            print("package[1] ", package[1])
            print("package[2] ", package[2])
            print("package[3] ", package[3])

            full_package = package[0] + '-' + package[1] + '-' + package[2] + '-' + package[3]
            print("full_package ", full_package)
            if line.startswith('Depends: '):
                # some plugins still reference twisted-* dependencies, these packages are now called python-twisted-*
                rdepends = []
                for depend in line[9:].split(','):
                    depend = depend.strip()
                    if depend.startswith('twisted-'):
                        rdepends.append(depend.replace('twisted-', 'python-twisted-'))
                    elif depend.startswith('enigma2') and not depend.startswith('enigma2-'):
                        pass # Ignore silly depends on enigma2 with all kinds of misspellings
                    else:
                        rdepends.append(depend)
                rdepends = ' '.join(rdepends)
                d.setVar('RDEPENDS_' + full_package, rdepends)
            elif line.startswith('Recommends: '):
                d.setVar('RRECOMMENDS_' + full_package, line[12:])
            elif line.startswith('Description: '):
                d.setVar('DESCRIPTION_' + full_package, line[13:])
            elif line.startswith('Replaces: '):
                d.setVar('RREPLACES_' + full_package, ' '.join(line[10:].split(', ')))
            elif line.startswith('Conflicts: '):
                d.setVar('RCONFLICTS_' + full_package, ' '.join(line[11:].split(', ')))
            elif line.startswith('Maintainer: '):
                d.setVar('MAINTAINER_' + full_package, line[12:])

    mydir = d.getVar('D', True) + "/../svn/titan/plugins/"
    print("mydir3 ", mydir)
#    for package in d.getVar('PACKAGES', d, 1).split():
#        getControlLines(mydir, d, package.split('-'))
}

#do_package_qa() {
#}

#PACKAGES_DYNAMIC = "titan-plugin-* titan-locale-*"

