SUMMARY = "KODI-Addons-meta"
inherit packagegroup

require conf/license/license-gplv2.inc


ALLOW_EMPTY:${PN} = "1"

RDEPENDS:${PN} = " \
    kodi-addon-pvr-demo \
    kodi-addon-pvr-njoy \
    kodi-addon-pvr-iptvsimple \
    "

#    kodi-addon-pvr-dvbviewer
#    kodi-addon-pvr-vdr.vnsi
#    kodi-addon-pvr-dvblink
#    kodi-addon-pvr-hts
#    kodi-addon-pvr-mythtv
#    kodi-addon-pvr-vuplus
#    kodi-addon-pvr-wmc
#    kodi-addon-pvr-nextpvr
#    kodi-addon-pvr-vbox
# fixme
#    kodi-addon-pvr-stalker
#    kodi-addon-pvr-filmon
#    kodi-addon-pvr-pctv
