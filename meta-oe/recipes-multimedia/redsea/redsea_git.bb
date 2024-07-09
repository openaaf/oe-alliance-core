SUMMARY = "A lightweight RDS decoder"
DESCRIPTION = "redsea is an experiment at building a lightweight command-line RDS decoder for Linux/OSX. It works with any RTL-SDR USB radio stick using the rtl_fm tool. It can also decode raw ASCII bitstream, the hex format used by RDS Spy, and multiplex signals (MPX)."
MAINTAINER = "Oona Räisänen <windyoona@gmail.com>"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=884926124e31c67b8c1bdaa062802dec"

DEPENDS = "nlohmann-json liquid-dsp virtual/libiconv libsndfile1"

inherit gittag

SRCREV = "${AUTOREV}"
<<<<<<< HEAD
PV = "0.18+git${SRCPV}"
PKGV = "0.18+git${GITPKGV}"
=======
PV = "git${SRCPV}"
PKGV = "${GITPKGVTAG}"
>>>>>>> 3b094b878f (readsea update 0.21 -> 1.0.0)

SRC_URI = "git://github.com/windytan/redsea.git;protocol=http;branch=master;protocol=https"

S = "${WORKDIR}/git"

<<<<<<< HEAD
inherit autotools-brokensep pkgconfig gettext

EXTRA_OECONF += "--disable-tmc --without-macports"
=======
inherit pkgconfig meson gettext
>>>>>>> 3b094b878f (readsea update 0.21 -> 1.0.0)
