SUMMARY = "openAAF Image"
SECTION = "base"
PRIORITY = "required"
LICENSE = "proprietary"
MAINTAINER = "openAAF team"

require conf/license/license-gplv2.inc

#PV = "${IMAGE_VERSION}"
#PR = "r${DATETIME}"
#PACKAGE_ARCH = "${MACHINE_ARCH}"
PV = "${IMAGE_VERSION}"
PR = "${BUILD_VERSION}"
PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup
#    ${DISTRO}-version-info
# FIX distro-image.bb ERROR: Taskhash mismatch - part 1 add packages to build dependencies of distro-image.bb which run on end of build process
DEPENDS = " \
	${DISTRO}-base \
    "

# FIX distro-image.bb ERROR: Taskhash mismatch - part 2  make sure all do_rm_work tasks of build dependencies are finished before starting do_rootfs of distro-image.bb
do_rootfs[deptask] = "do_rm_work"

IMAGE_INSTALL = "\
	${@bb.utils.contains("MACHINE_FEATURES", "boxmodel", "boxmodel", "", d)} \
	${DISTRO}-base \
   	titan \
	titan-plugin-tools-filemanager \
	titan-plugin-infos-imdbapi \
	titan-plugin-infos-imdb \
	titan-plugin-player-mc \
	titan-plugin-network-networkbrowser \
	titan-plugin-tools-readerconfig \
	titan-plugin-infos-streaminfo \
	titan-plugin-player-tithek \
	titan-plugin-infos-tmdb \
	titan-plugin-infos-weather \
	titan-plugin-skins-default \
    "

IMAGE_INSTALL_append_mipsel_aus = "\
	firmware-rtl8192cu \
	firmware-rt2870 \
	firmware-rt3070 \
	firmware-atheros-ar9271 \
	firmware-carl9170 \
	firmware-htc9271 \
	firmware-htc7010 \
	firmware-rtl8712u \
	firmware-rtl8192eu \
	kernel-module-ath9k \
	kernel-module-carl9170 \
	kernel-module-rt2800usb \
	rt3070 \
	rt8812au \
	rt8723a \
    "

IMAGE_INSTALL_append_arm_aus = "\
	firmware-rtl8192cu \
	firmware-rt2870 \
	firmware-rt3070 \
	firmware-atheros-ar9271 \
	firmware-carl9170 \
	firmware-htc9271 \
	firmware-htc7010 \
	firmware-rtl8712u \
	firmware-rtl8192eu \
	kernel-module-ath9k \
	kernel-module-carl9170 \
	kernel-module-rt2800usb \
	rt8812au \
	rt8723a \
    "

IMAGE_INSTALL_append_sh4_aus = "\
	firmware-rtl8192cu \
	firmware-rt2870 \
	firmware-rt3070 \
	firmware-atheros-ar9271 \
	firmware-carl9170 \
	firmware-htc9271 \
	firmware-htc7010 \
	firmware-rtl8712u \
	firmware-rtl8192eu \
	kernel-module-rt2800usb \
	rt3070 \
	rt8812au \
	rt8723a \
    "

# Some additional comfort on the shell: Pre-install nano on boxes with 128 MB or more:
IMAGE_INSTALL += "${@bb.utils.contains_any("FLASHSIZE", "64 96", "", "nano", d)}"

# ... plus mc and helpers on 256 MB or more:
IMAGE_INSTALL += "${@bb.utils.contains_any("FLASHSIZE", "64 96 128", "", "mc mc-fish mc-helpers", d)}"

export IMAGE_BASENAME = "openatv-image"
# 64 or 128MB of flash: No language files, above: German and French
IMAGE_LINGUAS  = "${@bb.utils.contains_any("FLASHSIZE", "64 96 128", "", "de-de fr-fr", d)}"

# Add more languages for 512 or more MB of flash:
IMAGE_LINGUAS += "${@bb.utils.contains_any("FLASHSIZE", "64 96 128 256", "", "es-es it-it nl-nl pt-pt", d)}"

IMAGE_FEATURES += "package-management"

INHIBIT_DEFAULT_DEPS = "1"

inherit image

do_package_index[nostamp] = "1"
do_package_index[depends] += "${PACKAGEINDEXDEPS}"

python do_package_index() {
    box = bb.data.expand('${MACHINEBUILD}', d)
    print("box ", box)

    mydir = d.getVar('D', True)
    print("mydir1 ", mydir)
    
    mydir2 = d.getVar('D', True) + "/../oe-rootfs-repo/" + box + "/preview"
    print("mydir2 ", mydir2)

    mydir3 = d.getVar('D', True) + "/../oe-rootfs-repo/" + box
    print("mydir3 ", mydir3)

    mydir4 = d.getVar('DEPLOY_DIR_IMAGE')
    print("mydir4 ", mydir4)

    mydir5 = d.getVar('DEPLOY_DIR_IPK')
    print("mydir5 ", mydir5)

    bb.process.run("pwd > /tmp/pwd2")

    bb.process.run("cd %s/%s; tar czvf Packages.preview.tar.gz ./preview" % (mydir5, box))

#cd "$HOMEDIR"
#tar czvf Packages.preview.tar.gz ./preview

#    deploydir = bb.data.expand('${DEPLOYDIR}', d)
#print("deploydir ", deploydir)


#bb.process.run("cp -a ../preview .")

    from oe.rootfs import generate_index_files
    generate_index_files(d)

    bb.process.run("pwd > /tmp/pwd3")

}
addtask do_package_index after do_rootfs before do_image_complete

