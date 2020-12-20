#!/bin/sh
# this script works only for /data/media

OP_ROOT_PATH=`/product/bin/laop_cmd getprop ro.vendor.lge.capp_cupss.op.dir`
SBP_VERSION=`/product/bin/laop_cmd getprop ro.vendor.lge.sbp.version`
OP_PRELOAD_TYPE=`/product/bin/laop_cmd getprop ro.vendor.lge.sbp.op_preloadtype`

CUPSS_ROOT_DIR=`getprop ro.vendor.lge.capp_cupss.rootdir`
PRODUCT_NAME=`getprop ro.product.name`

#log -p i -t runtime_boot_media_res "OP_ROOT_PATH = $OP_ROOT_PATH"
#log -p i -t runtime_boot_media_res "CUPSS_ROOT_DIR = $CUPSS_ROOT_DIR"
#log -p i -t runtime_boot_media_res "SBP_VERSION = $SBP_VERSION"
#log -p i -t runtime_boot_media_res "PRODUCT_NAME = $PRODUCT_NAME"
#log -p i -t runtime_boot_media_res "OP_PRELOAD_TYPE = $OP_PRELOAD_TYPE"

if [ -d /data/media/0/Preload ]; then
    chown -R media_rw:media_rw /data/media/0/Preload
    chmod 775 /data/media/0/Preload
    chmod 775 /data/media/0/Preload/LG
fi

OP_PRELOAD_DIR=("$OP_ROOT_PATH/_COMMON/media/Preload"
                "$OP_ROOT_PATH/_COMMON/media/Preload/LG"
                "$OP_ROOT_PATH/_COMMON/media/0/Preload/LG"
                "$CUPSS_ROOT_DIR/media/Preload"
                "$CUPSS_ROOT_DIR/media/Preload/LG")

OP_PRELOAD_POS_DONE="/data/media/op_preload_done.ini"
OP_PRELOAD_DONE="/data/system/op_preload_done.ini"
PRELOAD_LINK_LOCATION_DIR="/data/media/0/Preload"

if [ ${SBP_VERSION} -gt "30" ]; then
    if [ ! -f ${OP_PRELOAD_DONE} ]; then
        if [ ! -f ${OP_PRELOAD_POS_DONE} ]; then
            if [[ ${PRODUCT_NAME} == *"aosp"* ]]; then
                echo "op_preload_skip" > ${OP_PRELOAD_DONE}
            else
                mkdir -p ${PRELOAD_LINK_LOCATION_DIR}
                for PRELOAD_SUB_DIR in ${OP_PRELOAD_DIR[@]}; do
                    if [ -d ${PRELOAD_SUB_DIR} ]; then
                        PRELOAD_LIST=$(ls ${PRELOAD_SUB_DIR})
                        for PRELOAD_ITEM in ${PRELOAD_LIST}; do
                            if [ -f ${PRELOAD_SUB_DIR}/${PRELOAD_ITEM} ]; then
                                if [ "${OP_PRELOAD_TYPE}" == "copy" ]; then
                                    cp -rf ${PRELOAD_SUB_DIR}/${PRELOAD_ITEM} ${PRELOAD_LINK_LOCATION_DIR}/${PRELOAD_ITEM}
                                else
                                    ln -sfn ${PRELOAD_SUB_DIR}/${PRELOAD_ITEM} ${PRELOAD_LINK_LOCATION_DIR}/${PRELOAD_ITEM}
                                fi
                            fi
                        done
                    fi
                done

                chown -R media_rw:media_rw ${PRELOAD_LINK_LOCATION_DIR}
                chmod -R 0775 ${PRELOAD_LINK_LOCATION_DIR}
                echo "op_preload_done" > ${OP_PRELOAD_POS_DONE}
            fi
        fi
    fi
fi

# Trigger if LiveDemoUnit
IS_LIVE_DEMO_UNIT=`/product/bin/laop_cmd getprop persist.vendor.lge.LiveDemoUnit`
LDU_RES_SH=/product/bin/runtime_boot_ldu_res.sh
if [ "${IS_LIVE_DEMO_UNIT}" == "1" ]; then
    # Remove OP Preload Done file for Restore OP Preload Contents
    rm ${OP_PRELOAD_DONE}
    rm ${OP_PRELOAD_POS_DONE}
    # Restore LDU Contents
    if [ -f $LDU_RES_SH ]; then
        echo "start the "$LDU_RES_SH
        source $LDU_RES_SH
    fi
fi
exit 0
