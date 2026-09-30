SUMMARY = "OpenAAF Image"
SECTION = "base"
PRIORITY = "required"
LICENSE = "proprietary"
MAINTAINER = "openAAF team"

#disable if requrire by titan.bb
#require conf/license/license-gplv2.inc
require recipes-titan/titan/titan.bb

REPRODUCIBLE_TIMESTAMP_ROOTFS = "${@int(time.time()-10000)}"
#muss aus sein das SVN_VERSION gesetz wird aus titan.bb
#PV = "${IMAGE_VERSION}"
PR = "${BUILD_VERSION}"
PACKAGE_ARCH = "${MACHINE_ARCH}"

WORKDIR = "${TMPDIR}/work/${MULTIMACH_TARGET_SYS}/${PN}/${EXTENDPE}${PV}"

# We need to add machine rootfs directory to pseudo path after https://github.com/openembedded/openembedded-core/commit/2502da81709f25de499277b28d33c915638c45f6
PSEUDO_INCLUDE_PATHS .= ",${TMPDIR}/rootfs/${MACHINE}"

do_rootfs[deptask] = "do_rm_work"

SSTATE_ALLOW_OVERLAP_FILES += "${DEPLOY_DIR_IMAGE}"

IMAGE_INSTALL = "openaaf-base \
    ${@bb.utils.contains("MACHINE_FEATURES", "dvbc-only", "", "enigma2-plugin-settings-defaultsat", d)} \
    ${@bb.utils.contains("MACHINE_FEATURES", "no-cl-svr", "", \
    " \
    packagegroup-base-smbfs-client \
    packagegroup-base-smbfs-server \
    packagegroup-base-nfs \
    ", d)} \
    "

# Some additional comfort on the shell: Pre-install nano on boxes with 128 MB or more:
IMAGE_INSTALL += "${@bb.utils.contains_any("FLASHSIZE", "64 96", "", "nano", d)}"

# ... plus mc and helpers on 256 MB or more:
IMAGE_INSTALL += "${@bb.utils.contains_any("FLASHSIZE", "64 96 128", "", "mc mc-shell mc-helpers", d)}"

export IMAGE_BASENAME = "openaaf-image"

#ok1
#CREATE_CACHEDIR := "${@os.system('mkdir -p ${TMPDIR}/svncache/${MACHINEBUILD} > /dev/null 2>&1')}"
#GIT_VERSION := "${@os.popen('git --git-dir=${OE-ALLIANCE_BASE}/.git log  --pretty=format:"%s" | wc -l').read().rstrip()}"
#STABLE := "${@os.popen('svn export --force --username buildbin --password buildbin --force -r ${SVN_VERSION} http://svn.dyndns.tv/svn/image/make-flash ${TMPDIR}/svncache/${MACHINEBUILD}/make-flash | cat ${TMPDIR}/svncache/${MACHINEBUILD}/make-flash | grep ^STABLE= | cut -d"=" -f2 | tr -d "\r" | tr -d "\n" | sed -e "s/\t//g" | sed -e "s/ //g"').read().rstrip()}"
#STABLE_BRANCH := "${@os.popen('svn export --force --username buildbin --password buildbin --force -r ${SVN_VERSION} http://svn.dyndns.tv/svn/titan/titan/tools/oealliance.sh ${TMPDIR}/svncache/${MACHINEBUILD}/oealliance.sh | cat ${TMPDIR}/svncache/${MACHINEBUILD}/oealliance.sh | grep STABLEBRANCH= | sed -nr "s,.*=([^=]+).*,\1,p"').read().rstrip()}"
#TITAN_VERSION := "${@os.popen('svn export --force --username buildbin --password buildbin --force -r ${SVN_VERSION} http://svn.dyndns.tv/svn/titan/titan/struct.h ${TMPDIR}/svncache/${MACHINEBUILD}/struct.h | cat ${TMPDIR}/svncache/${MACHINEBUILD}/struct.h | grep "#define OVERSION" | cut -d\'"\' -f2 | sed "s/\./-/"').read().rstrip()}"
#IMAGE_VERSION_STRIP := "${@os.popen('echo ${IMAGE_VERSION} | sed "s/\./-/"').read().rstrip()}"
#GROUPOUT = "${@bb.utils.contains("SVN_VERSION", "${STABLE}", "stable", "nightly", d)}"
#export IMAGE_NAME = "${@bb.utils.contains("IMAGE_VERSION", "${STABLE_BRANCH}", "M${SVN_VERSION}_${MACHINEBUILD}_v${TITAN_VERSION}_${GROUPOUT}_UPDATEUSB_g${GIT_VERSION}", "M${SVN_VERSION}_${MACHINEBUILD}_v${TITAN_VERSION}_beta_UPDATEUSB_oe${IMAGE_VERSION_STRIP}_g${GIT_VERSION}", d)}"
#WRITE_IMAGE_NAME := "${@os.system('echo "${IMAGE_NAME}" > ${TMPDIR}/svncache/${MACHINEBUILD}/.imagename-oenew')}"

#ok2
COUNT := "${@os.popen('cat ${TMPDIR}/svncache/${MACHINEBUILD}/.COUNT').read().rstrip()}"
SVNVERSION := "${@os.popen('cat ${TMPDIR}/svncache/${MACHINEBUILD}/.COUNT').read().rstrip()}"
GITVERSION := "${@os.popen('git --git-dir=${OE-ALLIANCE_BASE}/.git log  --pretty=format:"%s" | wc -l').read().rstrip()}"
TITANVERSION := "${@os.popen('cat ${TMPDIR}/svncache/${MACHINEBUILD}/titanversion').read().rstrip()}"
STABLE := "${@os.popen('cat ${TMPDIR}/svncache/${MACHINEBUILD}/.STABLE').read().rstrip()}"
STABLEBRANCH := "${@os.popen('cat ${TMPDIR}/svncache/${MACHINEBUILD}/.STABLEBRANCH').read().rstrip()}"
IMAGE_VERSION_STRIP := "${@os.popen('echo ${IMAGE_VERSION} | sed "s/\./-/"').read().rstrip()}"
TITANVERSION_STRIP := "${@os.popen('echo ${TITANVERSION} | sed "s/\./-/"').read().rstrip()}"
GROUPOUT = "${@bb.utils.contains("SVNVERSION", "${STABLE}", "stable", "nightly", d)}"
#export IMAGE_NAME = "${@bb.utils.contains("IMAGE_VERSION", "${STABLEBRANCH}", "M${SVN_VERSION}_${MACHINEBUILD}_${TITANVERSION_STRIP}_${GROUPOUT}_UPDATEUSB_g${GITVERSION}", "M${SVN_VERSION}_${MACHINEBUILD}_${TITANVERSION_STRIP}_beta_UPDATEUSB_oe${IMAGE_VERSION_STRIP}_g${GITVERSION}", d)}"
export IMAGE_NAME = "${@bb.utils.contains("DISTRO_VERSION_OE", "${STABLEBRANCH}", "M${SVN_VERSION}_${MACHINEBUILD}_${TITANVERSION_STRIP}_${GROUPOUT}_UPDATEUSB_g${GITVERSION}", "M${SVN_VERSION}_${MACHINEBUILD}_${TITANVERSION_STRIP}_beta_UPDATEUSB_oe${IMAGE_VERSION_STRIP}_g${GITVERSION}", d)}"
WRITE_IMAGE_NAME := "${@os.system('echo "${IMAGE_NAME}" > ${TMPDIR}/svncache/${MACHINEBUILD}/.imagename-oenew')}"

#ok3
####export IMAGE_NAME:="${@os.popen('cat ${TMPDIR}/svncache/${MACHINEBUILD}/.imagename-svn').read().rstrip()}"

# Prevent locales-archive creation to save some space
IMAGE_LOCALES_ARCHIVE = ""

# 64 or 128MB of flash: No language files, above: German and French
IMAGE_LINGUAS  = "${@bb.utils.contains_any("FLASHSIZE", "64 96 128", "", "de-de fr-fr", d)}"

# Add more languages for 512 or more MB of flash:
IMAGE_LINGUAS += "${@bb.utils.contains_any("FLASHSIZE", "64 96 128 256", "", "es-es it-it nl-nl pt-pt", d)}"

IMAGE_FEATURES += "package-management allow-empty-password empty-root-password allow-root-login"

INHIBIT_DEFAULT_DEPS = "1"

inherit image

do_rootfs:append() {
    mydir = d.getVar('IMAGE_ROOTFS')
    print("mydir ", mydir)
    # fix settings restore
    bb.process.run("cp %s/mnt/settings/* %s/etc/titan.restore/mnt/settings; rm %s/mnt/settings; rm -rf %s/media/settings" % (mydir, mydir, mydir, mydir))
    # fix skin restore
    bb.process.run("ln -s /var/usr/local/share/titan/skin %s/lib/titan" % (mydir))
}

do_package_index[nostamp] = "1"
do_package_index[depends] += "${PACKAGEINDEXDEPS}"

python do_package_index() {
    from oe.rootfs import generate_index_files
    generate_index_files(d)
}
addtask do_package_index after do_rootfs before do_image_complete 
