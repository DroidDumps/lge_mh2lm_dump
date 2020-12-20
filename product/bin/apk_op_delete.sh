#!/bin/sh

CUST_NEXT_ROOT=`cat /persist-lg/property/persist.vendor.lge.cupss.next-root`
CUST_NEXT_ROOT=${CUST_NEXT_ROOT##*/}
OP_INFO=`cat /persist-lg/property/persist.vendor.lge.op_info`
DELEGATE_BUYERCODE=`getprop product.lge.sbp.opname`
DELEGATE_NTCODE=`cat /persist-lg/property/persist.vendor.lge.ntcode`
IS_MULTISIM=`cat /persist-lg/laop/legacy/ro.boot.vendor.lge.sim_num`
IS_CROSS_DOWNLOAD=`cat /persist-lg/laop/legacy/ro.vendor.lge.cross.download`
OP_ROOT_PATH=`cat /persist-lg/laop/legacy/ro.vendor.lge.capp_cupss.op.dir`
UI_BASE_CA=`getprop ro.vendor.lge.build.ui_base_ca`

if [ "${OP_ROOT_PATH}" == "" ] || [ ! -d "${OP_ROOT_PATH}" ]; then
    OP_ROOT_PATH="/OP"
fi
OP_PRIV_APP_DIR="${OP_ROOT_PATH}/priv-app"
OP_APP_DIR="${OP_ROOT_PATH}/app"

echo "[SBP] CUST_NEXT_ROOT: ${CUST_NEXT_ROOT}"
echo "[SBP] OP_ROOT_PATH: ${OP_ROOT_PATH}"
echo "[SBP] persist.vendor.lge.op_info: ${OP_INFO}"
echo "[SBP] persist.vendor.lge.ntcode: ${DELEGATE_NTCODE}"
echo "[SBP] ro.boot.vendor.lge.sim_num: ${IS_MULTISIM}"
echo "[SBP] ro.vendor.lge.cross.download: ${IS_CROSS_DOWNLOAD}"
echo "[SBP] ro.vendor.lge.build.ui_base_ca: ${UI_BASE_CA}"

if [  "${DELEGATE_BUYERCODE}" != "" ]; then
    echo "[SBP] Excute Delte dummy resources by buyer code!"
    ITEM=${DELEGATE_BUYERCODE};
elif [ "${CUST_NEXT_ROOT}" != "SUPERSET" ] && [ "${DELEGATE_NTCODE}" != "" ]; then
    echo "[SBP] Excute Delete dummy resources by ntcode!"
    ITEM=${OP_INFO}
fi

if [ "${ITEM}" != "" ]; then
    if [ "${IS_CROSS_DOWNLOAD}" == "1" ]; then
        if [ "${IS_MULTISIM}" == "1" ]; then
            if [ -d ${OP_ROOT_PATH}/${ITEM}_DS ]; then
                ITEM=${ITEM}_DS
            fi
        elif [ "${IS_MULTISIM}" == "2" ]; then
            if [ -d ${OP_ROOT_PATH}/${ITEM} ]; then
                ITEM=${ITEM}
            fi
        fi
    else
        if [ "${IS_MULTISIM}" == "2" ]; then
            if [ -d ${OP_ROOT_PATH}/${ITEM}_DS ]; then
                ITEM=${ITEM}_DS
            fi
        elif [ "${IS_MULTISIM}" == "3" ]; then
            if [ -d ${OP_ROOT_PATH}/${ITEM}_TS ]; then
                ITEM=${ITEM}_TS
            fi
        fi
    fi

    setprop product.lge.sbp.opname $ITEM

    # Delete other operator dir
    DEL_ENTRY=`ls -F ${OP_ROOT_PATH} | grep / | tr -d /`
    for del_item in $DEL_ENTRY
    do
        if [ "${del_item}" != "$ITEM" ] && [ "${del_item}" != "lost+found" ] && [ "${del_item}" != "_COMMON" ] && [ "${del_item}" != "priv-app" ] && [ "${del_item}" != "app" ]; then
            if [ -z $UI_BASE_CA ] || [ "${del_item}" != "${UI_BASE_CA}" ]; then
                rm -rf ${OP_ROOT_PATH}/$del_item
                echo "[SBP] rm -rf : OP/${del_item}"
                if [ -d "${OP_PRIV_APP_DIR}/$del_item" ]; then
                    rm -rf ${OP_PRIV_APP_DIR}/$del_item
                fi
                if [ -d "${OP_APP_DIR}/$del_item" ]; then
                    rm -rf ${OP_APP_DIR}/$del_item
                fi
            fi
        fi
    done
fi

#setprop persist.vendor.lge.data.opdeletion 1

exit 0
