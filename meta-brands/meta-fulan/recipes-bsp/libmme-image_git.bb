DESCRIPTION = "MME image library"

require ddt-apps.inc

DEPENDS += "jpeg"
PR = "r2"

FILES:${PN} += "${libdir}/libmmeimage.so"
FILES:${PN}-dev = "${includedir}/libmmeimage ${libdir}/libmmeimage.la"

INSANE_SKIP:${PN} += "dev-so"

do_install:append:openaaf () {
	install -d ${D}${includedir}/libmmeimage
	install -m 644 ${S}/*.h ${D}${includedir}/libmmeimage
}
