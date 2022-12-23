SUMMARY = "Titan packages require for image."
LICENSE = "MIT"
LIC_FILES:CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

ALLOW_EMPTY_${PN} = "1"

#PV = "1.0"
#PR = "r16"

inherit packagegroup

DEPENDS = " \
    titan-base \
	"

RDEPENDS:${PN} = "\
	titan-autorestore \
 	titan-infobox \
	titan-rarfs \
	titan-fbread \
	titan-tuxtxt \
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
    titan-plugin-settings-default.all \
    "
