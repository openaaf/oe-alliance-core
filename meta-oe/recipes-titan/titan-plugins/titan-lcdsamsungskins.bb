SUMMARY = "meta file for Titan LCD Samsung Skins"
inherit packagegroup

require conf/license/license-gplv2.inc

DEPENDS = "\
  titan-plugin-lcdsamsungskins-channel.analog.uhr \
  titan-plugin-lcdsamsungskins-channel_digital_uhr_gelb \
  titan-plugin-lcdsamsungskins-channel_digital_uhr_gelb_mod \
  titan-plugin-lcdsamsungskins-channel_digital_uhr_trikots \
  titan-plugin-lcdsamsungskins-digitaluhr_blau \
  titan-plugin-lcdsamsungskins-holzuhr.standby \
"

PR = "r0"
