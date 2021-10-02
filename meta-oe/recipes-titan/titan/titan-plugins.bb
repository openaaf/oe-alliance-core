SUMMARY = "TitanNit is a fast Linux Framebuffer Gui"
MAINTAINER = "TitanNit Team"
SECTION = "plugins"
#PRIORITY = "optional"
LICENSE = "GPLv2"
PACKAGE_ARCH = "${MACHINE_ARCH}"

require conf/license/license-gplv2.inc

SRCREV = "${AUTOREV}"
PV = "2.0+svnr${SRCPV}"
PR = "r1"

SRC_URI = "svn://sbnc.dyndns.tv/svn/;module=titan;protocol=http"

DEPENDS = "titan \
	${PYTHON_PN}-pyopenssl \
	${PYTHON_PN}-gdata \
	streamripper \
	${PYTHON_PN}-mutagen \
	${PYTHON_PN}-twisted \
	${PYTHON_PN}-daap \
	${PYTHON_PN}-google-api-client \
	${PYTHON_PN}-httplib2 \
	${PYTHON_PN}-youtube-dl \
	libtirpc \
	"

RDEPENDS:${PN} = "${PYTHON_PN}-ctypes"

S = "${WORKDIR}/titan/plugins"

inherit autotools-brokensep

CFLAGS:append = " \
	-I${STAGING_DIR_TARGET}/usr/include \
	-I${STAGING_DIR_TARGET}/usr/include/freetype2 \
	-I${STAGING_DIR_TARGET}/usr/include/openssl \
	-I${STAGING_DIR_TARGET}/usr/include/dreamdvd \
	-I${STAGING_DIR_TARGET}/usr/include/libdreamdvd \
	-I${STAGING_DIR_TARGET}/usr/include/curl \
	-I${STAGING_DIR_TARGET}/usr/include/tirpc \
	-I${STAGING_DIR_TARGET}/usr/include/python3.9 \
	-I${WORKDIR}/titan/libdreamdvd \
	-I${WORKDIR}/titan/titan \
	-I${WORKDIR}/titan/titan/include \
	-I${WORKDIR}/titan/libeplayer3/include \
	"

CFLAGS:append:arm = "${@bb.utils.contains('GST_VERSION', '1.0', ' \
	-I${STAGING_DIR_TARGET}/usr/include \
	-I${STAGING_DIR_TARGET}/usr/lib/gstreamer-1.0/include \
	-I${STAGING_DIR_TARGET}/usr/include/gstreamer-1.0 \
	-I${STAGING_DIR_TARGET}/usr/include/glib-2.0 \
	-I${STAGING_DIR_TARGET}/usr/include/libxml2 \
	-I${STAGING_DIR_TARGET}/usr/lib/glib-2.0/include \
	-I${STAGING_DIR_TARGET}/usr/include/freetype2 \
	-I${STAGING_DIR_TARGET}/usr/include/dreamdvd \
	-I${STAGING_DIR_TARGET}/usr/include/libdreamdvd \	
	-I${WORKDIR}/titan/libdreamdvd \
	-I${WORKDIR}/titan/titan \
    ', ' \
	-I${STAGING_DIR_TARGET}/usr/include \
	-I${STAGING_DIR_TARGET}/usr/include/gstreamer-0.10 \
	-I${STAGING_DIR_TARGET}/usr/include/glib-2.0 \
	-I${STAGING_DIR_TARGET}/usr/include/libxml2 \
	-I${STAGING_DIR_TARGET}/usr/lib/glib-2.0/include \
	-I${STAGING_DIR_TARGET}/usr/include/freetype2 \
	-I${STAGING_DIR_TARGET}/usr/include/dreamdvd \
	-I${STAGING_DIR_TARGET}/usr/include/libdreamdvd \	
	-I${WORKDIR}/titan/libdreamdvd \
	-I${WORKDIR}/titan/titan \
', d)}"

CFLAGS:append:sh4 = " \
	-I${STAGING_DIR_TARGET}/usr/include/libmmeimage \
	-I${STAGING_KERNEL_DIR}/extra/bpamem \
	"

CFLAGS:append:sh4 = " -DOEBUILD -DEXTEPLAYER3 -DEPLAYER3 -DSH4 -DSH4NEW -DCAMSUPP -Os -export-dynamic -Wall -Wno-unused-but-set-variable -Wno-implicit-function-declaration"
CFLAGS:append:mipsel = " -DOEBUILD -DEXTEPLAYER3 -DEPLAYER3 -DCAMSUPP -Os -mhard-float -export-dynamic -Wall -Wno-unused-but-set-variable -Wno-implicit-function-declaration -Wno-unused-variable -Wno-format-overflow -Wno-format-truncation -Wno-nonnull -Wno-restrict"
CFLAGS:append:arm = " -DOEBUILD -DEXTEPLAYER3 -DEPLAYER3 -DCAMSUPP -Os -mhard-float -export-dynamic -Wall -Wno-unused-but-set-variable -Wno-implicit-function-declaration -Wno-unused-variable -Wno-format-overflow -Wno-format-truncation -Wno-nonnull -Wno-restrict"

LDFLAGS:prepend = " -lcurl "

do_configure:prepend() {
	cd ${S}

	SVNVERSION=`echo ${WORKDIR} | sed -nr 's/.*svnr([^.*]+)-.*/\1/p'`
	echo SVNVERSION: ${SVNVERSION}

	sed "s/^#define PLUGINVERSION .*/#define PLUGINVERSION $SVNVERSION/" -i  ../titan/struct.h
	cat ../titan/struct.h | grep "define PLUGINVERSION"
}

EXTRA_OECONF = " \
    BUILD_SYS=${BUILD_SYS} \
    HOST_SYS=${HOST_SYS} \
    STAGING_INCDIR=${STAGING_INCDIR} \
    STAGING_LIBDIR=${STAGING_LIBDIR} \
"

FILES:${PN} = "/usr/local/share/titan/plugins"

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
		if test -e ../skins/$ROUND/picons;then
			cp -a ../skins/$ROUND/picons ${D}/usr/local/share/titan/plugins/$ROUND/
		fi
		if test -e ../skins/$ROUND/skin;then
			cp -a ../skins/$ROUND/skin ${D}/usr/local/share/titan/plugins/$ROUND/
		fi
		if test -e ../skins/$ROUND/skin.xml;then
			install -m 0644 ../skins/$ROUND/skin.xml ${D}/usr/local/share/titan/plugins/$ROUND/
		fi
		if test -e ../skins/$ROUND/plugin.png;then
			install -m 0644 ../skins/$ROUND/plugin.png ${D}/usr/local/share/titan/plugins/$ROUND/
		fi
		if test -e ../skins/$ROUND/default.jpg;then
			install -m 0644 ../skins/$ROUND/default.jpg ${D}/usr/local/share/titan/plugins/$ROUND/
		fi
	done
}

python populate_packages:prepend() {
    titan_plugindir = bb.data.expand('/usr/local/share/titan/plugins', d)
    do_split_packages(d, titan_plugindir, '^(\w+)/[a-zA-Z0-9_]+.*$', 'titan-plugin-%s', '%s', recursive=True, match_path=True, prepend=True, extra_depends="titan")
    do_split_packages(d, titan_plugindir, '^(\w+)/.*\.h$', 'titan-plugin-%s-src', '%s (source files)', recursive=True, match_path=True, prepend=True)
    do_split_packages(d, titan_plugindir, '^(\w+)/.*\.la$', 'titan-plugin-%s-dev', '%s (development)', recursive=True, match_path=True, prepend=True)
    do_split_packages(d, titan_plugindir, '^(\w+)/.*\.a$', 'titan-plugin-%s-staticdev', '%s (static development)', recursive=True, match_path=True, prepend=True)
    do_split_packages(d, titan_plugindir, '^(\w+)/(.*/)?\.debug/.*$', 'titan-plugin-%s-dbg', '%s (debug)', recursive=True, match_path=True, prepend=True)

    titan_podir = bb.data.expand('/usr/local/share/titan/po', d)
    do_split_packages(d, titan_podir, '^(\w+)/[a-zA-Z0-9_/]+.*$', 'titan-locale-%s', '%s', recursive=True, match_path=True, prepend=True, extra_depends="titan")
}

PACKAGES_DYNAMIC = "titan-plugin-* titan-locale-*"
