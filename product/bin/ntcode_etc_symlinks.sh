#!/bin/sh
LOG_TAG="laop_symlinks"

LAST_BUILD_INCREMENTAL=`/product/bin/laop_cmd getprop persist.vendor.lge.laop.incremental 0`
CURRENT_BUILD_INCREMENTAL=`getprop ro.build.version.incremental NODEF`

if [[ "$LAST_BUILD_INCREMENTAL" == "$CURRENT_BUILD_INCREMENTAL" ]]; then
    exit 0;
fi

SOURCE_PATH=`getprop ro.vendor.lge.capp_cupss.rootdir /cust`   #/cust/VDF_COM

# TODO: Remove below lines from Q-OS - START
OP_PATH=`/product/bin/laop_cmd getprop persist.vendor.lge.op_info NODEF`
if [[ "$OP_PATH" == "NODEF" ]]; then
    IS_MULTISIM=`/product/bin/laop_cmd getprop ro.boot.vendor.lge.sim_num 1`
    OPERATOR=`getprop ro.vendor.lge.build.target_operator GLOBAL`
    COUNTRY=`getprop ro.vendor.lge.build.target_country COM`

    if [ $IS_MULTISIM == "2" ]; then
        OP_PATH=${OPERATOR}_${COUNTRY}_DS
    elif [ $IS_MULTISIM == "3" ]; then
        OP_PATH=${OPERATOR}_${COUNTRY}_TS
    else
        OP_PATH=${OPERATOR}_${COUNTRY}
    fi
fi
LEGACY_OP_PATH=/OP/${OP_PATH}
# TODO: Remove below lines from Q-OS - END

SOURCE_ETC_PATH=${SOURCE_PATH}/etc
TARGET_ETC_PATH=/data/laop/etc

# /data/local/etc MUST be updated in MR or OSU.
log -p i -t ${LOG_TAG} "[SBP] clean-up /data/local/etc for MR or OSU"
rm -rf ${TARGET_ETC_PATH}/*

if [ ! -d ${TARGET_ETC_PATH} ]; then
    log -p i -t ${LOG_TAG} "[SBP] mkdir ${TARGET_ETC_PATH}"
    mkdir -p -m 771 ${TARGET_ETC_PATH}
    restorecon ${TARGET_ETC_PATH}
fi

if [ ! -d ${TARGET_ETC_PATH} ]; then
    log -p e -t ${LOG_TAG} "[SBP] exit - cannot mkdir ${TARGET_ETC_PATH}"
    exit 0;
fi
#log -p i -t ${LOG_TAG} "[SBP] SOURCE_PATH = $SOURCE_PATH"
#log -p i -t ${LOG_TAG} "[SBP] LAST_BUILD_INCREMENTAL = $LAST_BUILD_INCREMENTAL"
#log -p i -t ${LOG_TAG} "[SBP] CURRENT_BUILD_INCREMENTAL = $CURRENT_BUILD_INCREMENTAL"
#log -p i -t ${LOG_TAG} "[SBP] OP_PATH = $OP_PATH"
#log -p i -t ${LOG_TAG} "[SBP] IS_MULTISIM = $IS_MULTISIM"

# copy 3rd party app properties for LGE to /data
LGE_3RD_PARTY_KEY_PATH=/system/vendor/etc/LGE
if [ -d ${LGE_3RD_PARTY_KEY_PATH} ]; then
    cp -rpf ${LGE_3RD_PARTY_KEY_PATH}/* ${TARGET_ETC_PATH}/
fi

# Read NT-Code MCC
NTCODE=`/product/bin/laop_cmd getprop ro.vendor.lge.ntcode_mcc XXX`
if [[ "$NTCODE" == "XXX" ]]; then
    #Nothing to do - fail to read ntcode
    log -p e -t ${LOG_TAG} "[SBP] exit - fail to read ntcode"
fi

# For dedicatie operator with speical NT-code, eg., VDF: "2","FFF,FFF,FFFFFFFF,FFFFFFFF,11","999,01F,FFFFFFFF,FFFFFFFF,FF"
MCCMNC_LIST=`/product/bin/laop_cmd getprop persist.vendor.lge.mccmnc-list "FFFFF"`

DEDICATE_OPERATOR_MCCMNC="XXXXXX"
if [[ "$MCCMNC_LIST" == *"999"* ]]; then
    DEDICATE_OPERATOR_MCCMNC=${MCCMNC_LIST%%999*}
    DEDICATE_MCCMNC_INDEX=${#DEDICATE_OPERATOR_MCCMNC}
    DEDICATE_OPERATOR_MCCMNC=${MCCMNC_LIST:$DEDICATE_MCCMNC_INDEX:6}
    DEDICATE_OPERATOR_MCCMNC=${DEDICATE_OPERATOR_MCCMNC%,}
fi

if [ -d ${SOURCE_ETC_PATH}/${DEDICATE_OPERATOR_MCCMNC} ]; then
    cp -rpf ${SOURCE_ETC_PATH}/${DEDICATE_OPERATOR_MCCMNC}/* ${TARGET_ETC_PATH}/
    log -p i -t ${LOG_TAG} "[SBP] cp -rpf ${SOURCE_ETC_PATH}/${DEDICATE_OPERATOR_MCCMNC}/* ${TARGET_ETC_PATH}/"
elif [ -d ${SOURCE_ETC_PATH}/${NTCODE} ]; then
    cp -rpf ${SOURCE_ETC_PATH}/${NTCODE}/* ${TARGET_ETC_PATH}/
    log -p i -t ${LOG_TAG} "[SBP] cp -rpf ${SOURCE_ETC_PATH}/${NTCODE}/* ${TARGET_ETC_PATH}/"
elif [ -d ${SOURCE_ETC_PATH}/FFF ]; then
    cp -rpf ${SOURCE_ETC_PATH}/FFF/* ${TARGET_ETC_PATH}/
    log -p i -t ${LOG_TAG} "[SBP] cp -rpf ${SOURCE_ETC_PATH}/FFF/* ${TARGET_ETC_PATH}/"

# TODO: Remove below lines from Q-OS - START
# Support Legacy locations
elif [ -d ${SOURCE_PATH}/prop/${DEDICATE_OPERATOR_MCCMNC} ]; then
    cp -rpf ${SOURCE_PATH}/prop/${DEDICATE_OPERATOR_MCCMNC}/* ${TARGET_ETC_PATH}/
    log -p i -t ${LOG_TAG} "[SBP] cp -rpf ${SOURCE_PATH}/prop/${DEDICATE_OPERATOR_MCCMNC}/* ${TARGET_ETC_PATH}/"
elif [ -d ${SOURCE_PATH}/config/apps_prop/${DEDICATE_OPERATOR_MCCMNC} ]; then
    cp -rpf ${SOURCE_PATH}/config/apps_prop/${DEDICATE_OPERATOR_MCCMNC}/* ${TARGET_ETC_PATH}/
    log -p i -t ${LOG_TAG} "[SBP] ${SOURCE_PATH}/config/apps_prop/${DEDICATE_OPERATOR_MCCMNC}/* ${TARGET_ETC_PATH}/"
elif [ -d ${LEGACY_OP_PATH}/prop/${DEDICATE_OPERATOR_MCCMNC} ]; then
    cp -rpf ${LEGACY_OP_PATH}/prop/${DEDICATE_OPERATOR_MCCMNC}/* ${TARGET_ETC_PATH}/
    log -p i -t ${LOG_TAG} "[SBP] cp -rpf ${LEGACY_OP_PATH}/prop/${DEDICATE_OPERATOR_MCCMNC}/* ${TARGET_ETC_PATH}/"
elif [ -d ${LEGACY_OP_PATH}/config/apps_prop/${DEDICATE_OPERATOR_MCCMNC} ]; then
    cp -rpf ${LEGACY_OP_PATH}/config/apps_prop/${DEDICATE_OPERATOR_MCCMNC}/* ${TARGET_ETC_PATH}/
    log -p i -t ${LOG_TAG} "[SBP] cp -rpf ${LEGACY_OP_PATH}/config/apps_prop/${DEDICATE_OPERATOR_MCCMNC}/* ${TARGET_ETC_PATH}/"

elif [ -d ${SOURCE_PATH}/prop/${NTCODE} ]; then
    cp -rpf ${SOURCE_PATH}/prop/${NTCODE}/* ${TARGET_ETC_PATH}/
    log -p i -t ${LOG_TAG} "[SBP] cp -rpf ${SOURCE_PATH}/prop/${NTCODE}/* ${TARGET_ETC_PATH}/"
elif [ -d ${SOURCE_PATH}/config/apps_prop/${NTCODE} ]; then
    cp -rpf ${SOURCE_PATH}/config/apps_prop/${NTCODE}/* ${TARGET_ETC_PATH}/
    log -p i -t ${LOG_TAG} "[SBP] cp -rpf ${SOURCE_PATH}/config/apps_prop/${NTCODE}/* ${TARGET_ETC_PATH}/"
elif [ -d ${LEGACY_OP_PATH}/prop/${NTCODE} ]; then
    cp -rpf ${LEGACY_OP_PATH}/prop/${NTCODE}/* ${TARGET_ETC_PATH}/
    log -p i -t ${LOG_TAG} "[SBP] cp -rpf ${LEGACY_OP_PATH}/prop/${NTCODE}/* ${TARGET_ETC_PATH}/"
elif [ -d ${LEGACY_OP_PATH}/config/apps_prop/${NTCODE} ]; then
    cp -rpf ${LEGACY_OP_PATH}/config/apps_prop/${NTCODE}/* ${TARGET_ETC_PATH}/
    log -p i -t ${LOG_TAG} "[SBP] cp -rpf ${LEGACY_OP_PATH}/config/apps_prop/${NTCODE}/* ${TARGET_ETC_PATH}/"

elif [ -d ${SOURCE_PATH}/prop/FFF ]; then
    cp -rpf ${SOURCE_PATH}/prop/FFF/* ${TARGET_ETC_PATH}/
    log -p i -t ${LOG_TAG} "[SBP] cp -rpf ${SOURCE_PATH}/prop/FFF/* ${TARGET_ETC_PATH}/"
elif [ -d ${SOURCE_PATH}/config/apps_prop/FFF ]; then
    cp -rpf ${SOURCE_PATH}/config/apps_prop/FFF/* ${TARGET_ETC_PATH}/
    log -p i -t ${LOG_TAG} "[SBP] cp -rpf ${SOURCE_PATH}/config/apps_prop/FFF/* ${TARGET_ETC_PATH}/"
elif [ -d ${LEGACY_OP_PATH}/prop/FFF ]; then
    cp -rpf ${LEGACY_OP_PATH}/prop/FFF/* ${TARGET_ETC_PATH}/
    log -p i -t ${LOG_TAG} "[SBP] cp -rpf ${LEGACY_OP_PATH}/prop/FFF/* ${TARGET_ETC_PATH}/"
elif [ -d ${LEGACY_OP_PATH}/config/apps_prop/FFF ]; then
    cp -rpf ${LEGACY_OP_PATH}/config/apps_prop/FFF/* ${TARGET_ETC_PATH}/
    log -p i -t ${LOG_TAG} "[SBP] cp -rpf ${LEGACY_OP_PATH}/config/apps_prop/FFF/* ${TARGET_ETC_PATH}/"
# TODO: Remove below lines from Q-OS - END

fi

# Restore sap_etc_symlink in MR
FIXED_FIRST_SIM_OPERATOR=`/product/bin/laop_cmd getprop persist.vendor.lge.sim.operator.first NODEF`
if [[ "$FIXED_FIRST_SIM_OPERATOR" != "NODEF" ]]; then
    if [ -d ${SOURCE_ETC_PATH}/${FIXED_FIRST_SIM_OPERATOR} ]; then
        cp -rpf ${SOURCE_ETC_PATH}/${FIXED_FIRST_SIM_OPERATOR}/* ${TARGET_ETC_PATH}/
        log -p i -t ${LOG_TAG} "[SBP] cp -rpf ${SOURCE_ETC_PATH}/${FIXED_FIRST_SIM_OPERATOR}/* ${TARGET_ETC_PATH}/"
# TODO: Remove below lines from Q-OS - START
    elif [ -d ${SOURCE_PATH}/prop/${FIXED_FIRST_SIM_OPERATOR} ]; then
        cp -rpf ${SOURCE_PATH}/prop/${FIXED_FIRST_SIM_OPERATOR}/* ${TARGET_ETC_PATH}/
        log -p i -t ${LOG_TAG} "[SBP] cp -rpf ${SOURCE_PATH}/prop/${FIXED_FIRST_SIM_OPERATOR}/* ${TARGET_ETC_PATH}/"
    elif [ -d ${SOURCE_PATH}/config/apps_prop/${FIXED_FIRST_SIM_OPERATOR} ]; then
        cp -rpf ${SOURCE_PATH}/config/apps_prop/${FIXED_FIRST_SIM_OPERATOR}/* ${TARGET_ETC_PATH}/
        log -p i -t ${LOG_TAG} "[SBP] cp -rpf ${SOURCE_PATH}/config/apps_prop/${FIXED_FIRST_SIM_OPERATOR}/* ${TARGET_ETC_PATH}/"
# TODO: Remove below lines from Q-OS - END
    fi
fi

# Smart-CA configuration is top prioirty.
SMARTCA_ETC_PATH="/data/shared/cust/etc"
if [ -d ${SMARTCA_ETC_PATH} ];then
    cp -rpf ${SMARTCA_ETC_PATH}/* ${TARGET_ETC_PATH}/
    log -p i -t ${LOG_TAG} "[SBP] cp -rpf ${SMARTCA_ETC_PATH}/* ${TARGET_ETC_PATH}/"
fi

EEA_PATH=`getprop ro.boot.product.lge.eea_type NODEF`
if  [[ "$EEA_PATH" == "4c" ]] ; then
    cp -rpf ${SOURCE_ETC_PATH}/sysconfig/eea_search_chrome.xml ${TARGET_ETC_PATH}/
    log -p i -t ${LOG_TAG} "[SBP] cp -rpf ${SOURCE_ETC_PATH}/sysconfig/eea_search_chrome.xml ${TARGET_ETC_PATH}/"
fi

chown -R system:system ${TARGET_ETC_PATH}/*
chmod -R 644 ${TARGET_ETC_PATH}/*

# Change directory permission to get read
find ${TARGET_ETC_PATH} -type d -exec chmod 755 {} +

/product/bin/laop_cmd setprop persist.vendor.lge.laop.incremental ${CURRENT_BUILD_INCREMENTAL}
exit 0
