SUMMARY = "openAAF version info"
SECTION = "base"
PRIORITY = "required"
LICENSE = "proprietary"
MAINTAINER = "openAAF"

require conf/license/license-gplv2.inc

PV = "${IMAGE_VERSION}"
PR = "${BUILD_VERSION}"
PACKAGE_ARCH = "${MACHINEBUILD}"

URL = "http://www.aaf-digital.info"

do_configure[nostamp] = "1"

S = "${WORKDIR}"

PACKAGES = "${PN}"

do_install() {
    install -d ${D}/etc
    echo "box_type=${MACHINEBUILD}" > ${D}/etc/image-version-git
    echo "build_type=${BUILDTYPE}" >> ${D}/etc/image-version-git
    echo "machine_brand=${MACHINE_BRAND}" >> ${D}/etc/image-version-git
    echo "machine_name=${MACHINE_NAME}" >> ${D}/etc/image-version-git
    echo "version=${IMAGE_VERSION}" >> ${D}/etc/image-version-git
    echo "build=${BUILD_VERSION}" >> ${D}/etc/image-version-git
    echo "date=${DATETIME}" >> ${D}/etc/image-version-git
    echo "comment=openATV" >> ${D}/etc/image-version-git
    echo "target=9" >> ${D}/etc/image-version-git
    echo "creator=openATV" >> ${D}/etc/image-version-git
    echo "url=${URL}" >> ${D}/etc/image-version-git
    echo "catalog=${URL}" >> ${D}/etc/image-version-git
    echo "oever=${OE_VER}" >> ${D}/etc/image-version-git
    echo "distro=${DISTRO_NAME}" >> ${D}/etc/image-version-git
    echo "brandoem=${BRAND_OEM}" >> ${D}/etc/image-version-git
    echo "machinemake=${MACHINEBUILD}" >> ${D}/etc/image-version-git
    echo "imageversion=${DISTRO_VERSION}" >> ${D}/etc/image-version-git
    echo "imagebuild=${BUILD_VERSION}" >> ${D}/etc/image-version-git
    echo "imagedevbuild=${DEVELOPER_BUILD_VERSION}" >> ${D}/etc/image-version-git
    echo "imagetype=${DISTRO_TYPE}" >> ${D}/etc/image-version-git
    echo "feedsurl=${DISTRO_FEED_URI}" >> ${D}/etc/image-version-git
    echo "imagedir=${IMAGEDIR}" >> ${D}/etc/image-version-git
    echo "imagefs=${IMAGE_FSTYPES}" >> ${D}/etc/image-version-git
    echo "mtdrootfs=${MTD_ROOTFS}" >> ${D}/etc/image-version-git
    echo "mtdkernel=${MTD_KERNEL}" >> ${D}/etc/image-version-git
    echo "rootfile=${ROOTFS_FILE}" >> ${D}/etc/image-version-git
    echo "kernelfile=${KERNEL_FILE}" >> ${D}/etc/image-version-git
    echo "mkubifs=${MKUBIFS_ARGS}" >> ${D}/etc/image-version-git
    echo "ubinize=${UBINIZE_ARGS}" >> ${D}/etc/image-version-git
    echo "driverdate=${DRIVERSDATE}" >> ${D}/etc/image-version-git
    echo "arch=${DEFAULTTUNE}" >> ${D}/etc/image-version-git
    echo "display-type=${DISPLAY_TYPE}" >> ${D}/etc/image-version-git
    echo "hdmi=${HAVE_HDMI}" >> ${D}/etc/image-version-git
    echo "yuv=${HAVE_YUV}" >> ${D}/etc/image-version-git
    echo "rca=${HAVE_RCA}" >> ${D}/etc/image-version-git
    echo "av-jack=${HAVE_AV_JACK}" >> ${D}/etc/image-version-git
    echo "scart=${HAVE_SCART}" >> ${D}/etc/image-version-git
    echo "scart-yuv=${HAVE_SCART_YUV}" >> ${D}/etc/image-version-git
    echo "dvi=${HAVE_DVI}" >> ${D}/etc/image-version-git
    echo "minitv=${HAVE_MINITV}" >> ${D}/etc/image-version-git
    echo "hdmi-in-hd=${HAVE_HDMI_IN_HD}" >> ${D}/etc/image-version-git
    echo "hdmi-in-fhd=${HAVE_HDMI_IN_FHD}" >> ${D}/etc/image-version-git
    echo "wol=${HAVE_WOL}" >> ${D}/etc/image-version-git
    echo "wwol=${HAVE_WWOL}" >> ${D}/etc/image-version-git
    echo "ci=${HAVE_CI}" >> ${D}/etc/image-version-git
    echo "transcoding=${TRANSCODING}" >> ${D}/etc/image-version-git
    echo "${MACHINE}" > ${D}/etc/model
}
do_install[vardepsexclude] += "DATETIME"

FILES_${PN} += "/etc/model /etc/image-version-git /etc/oe-git.log /etc/e2-git.log"

