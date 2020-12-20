#!/bin/sh

OPERATOR=`getprop ro.vendor.lge.build.target_operator`
COTA_FLAG=`/product/bin/laop_cmd getprop persist.vendor.lge.cota.changed`
SMARTCA_FLAG=`/product/bin/laop_cmd getprop persist.vendor.lge.smartca.changed`
OP_INTEGRATION=`/product/bin/laop_cmd getprop ro.vendor.lge.op.integration`
OP_ROOT_PATH=`/product/bin/laop_cmd getprop ro.vendor.lge.capp_cupss.op.dir`

if [ "$OP_INTEGRATION" == "1" ]; then
    if [ "$OP_ROOT_PATH" == "/OP" ]; then
        CUPSS_DEFAULT_PATH=/OP
    else
        CUPSS_DEFAULT_PATH=/mnt/product/carrier
    fi
    RES_PATH=_SMARTCA_RES
else
    CUPSS_DEFAULT_PATH=/cust
    RES_PATH=_COTA_RES
fi


if [ "$COTA_FLAG" == "2" ]; then
    # set 3 to distinguish cota task done
    /product/bin/laop_cmd setprop persist.vendor.lge.cota.changed 3
    exit 0
fi

if [ "$SMARTCA_FLAG" == "2" ]; then
    # set 3 to distinguish cota task done
    /product/bin/laop_cmd setprop persist.vendor.lge.smartca.changed 3
    exit 0
fi

if [ $OPERATOR == "GLOBAL" -a "$COTA_FLAG" == "1" ]; then
    # In case of SUPERSET in MID process,
    # prevent copying cota bootanimation, in ResourcePackageManagmer, to cust.
    /product/bin/laop_cmd setprop persist.vendor.lge.cota.changed 2
    exit 0
fi

if [ $OPERATOR == "GLOBAL" -a "$SMARTCA_FLAG" == "1" ]; then
    # In case of SUPERSET in MID process,
    # prevent copying smartca bootanimation, in ResourcePackageManagmer, to OP.
    /product/bin/laop_cmd setprop persist.vendor.lge.smartca.changed 2
    exit 0
fi

chown -R system:system /data/shared/cust
chmod 775 /data/shared/cust
chmod 775 /data/shared/cust/*

chown -R system:system ${CUPSS_DEFAULT_PATH}/${RES_PATH}
chmod 775 ${CUPSS_DEFAULT_PATH}/${RES_PATH}
chmod 775 ${CUPSS_DEFAULT_PATH}/${RES_PATH}/*


if [ $(ls /data/shared/cust/PowerOn.ogg) ]; then
    cp -pf /data/shared/cust/PowerOn.ogg ${CUPSS_DEFAULT_PATH}/${RES_PATH}
fi

if [ $(ls /data/shared/cust/bootanimation.zip) ]; then
    cp -pf /data/shared/cust/bootanimation.zip ${CUPSS_DEFAULT_PATH}/${RES_PATH}
fi

if [ "$COTA_FLAG" == "1" ]; then
    # Trigger For cust partition rw remount
    /product/bin/laop_cmd setprop persist.vendor.lge.cota.changed 2
fi

if [ "$SMARTCA_FLAG" == "1" ]; then
    # Trigger For OP partition rw remount
    /product/bin/laop_cmd setprop persist.vendor.lge.smartca.changed 2
fi

exit 0
