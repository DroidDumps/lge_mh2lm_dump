#!/bin/sh
OP_INTEGRATION=`/product/bin/laop_cmd getprop ro.vendor.lge.op.integration`
OP_ROOT_PATH=`/product/bin/laop_cmd getprop ro.vendor.lge.capp_cupss.op.dir`
SMARTCA_UNDO_FLAG=`/product/bin/laop_cmd getprop persist.vendor.lge.smartca.undo`


if [ "$OP_INTEGRATION" == "1" ]; then
    CUPSS_DEFAULT_PATH=$OP_ROOT_PATH
    RES_PATH=_SMARTCA_RES
    if [ "$OP_ROOT_PATH" == "/OP" ]; then
        COTA_RES_ROOT_PATH=$CUPSS_DEFAULT_PATH
    else
        COTA_RES_ROOT_PATH=/mnt/product/carrier
    fi
else
    CUPSS_DEFAULT_PATH=/cust
    RES_PATH=_COTA_RES
fi

BOOTANIM_FILE=bootanimation_
HYDRA_PROP=`getprop ro.boot.vendor.lge.hydra NONE`
HYDRA_PROP_LOWERCASE=`echo $HYDRA_PROP | tr [:upper:] [:lower:]`
HYDRA_BOOTANIMATION_FILE=`echo $BOOTANIM_FILE${HYDRA_PROP}.zip`
HYDRA_BOOTANIMATION_FILE_LOWERCASE=`echo $BOOTANIM_FILE${HYDRA_PROP_LOWERCASE}.zip`

COTA_BOOTANIMATION_FILE=${COTA_RES_ROOT_PATH}/${RES_PATH}/bootanimation.zip
COTA_BOOTANIMATION_SOUND_FILE=${COTA_RES_ROOT_PATH}/${RES_PATH}/PowerOn.ogg
COTA_SHARED_BOOTANIMATION_FILE=/data/shared/cust/bootanimation.zip
COTA_SHARED_BOOTANIMATION_SOUND_FILE=/data/shared/cust/PowerOn.ogg
COTA_SHUTDOWNANIMATION_FILE=/data/shared/cust/shutdownanimation.zip
COTA_SHUTDOWNANIMATION_SOUND_FILE=/data/shared/cust/PowerOff.ogg

COTA_HYDRA_BOOTANIMATION_FILE=${COTA_RES_ROOT_PATH}/${RES_PATH}/$HYDRA_BOOTANIMATION_FILE
COTA_HYDRA_BOOTANIMATION_FILE_LOWERCASE=${COTA_RES_ROOT_PATH}/${RES_PATH}/$HYDRA_BOOTANIMATION_FILE_LOWERCASE
COTA_SHARED_HYDRA_BOOTANIMATION_FILE=/data/shared/cust/$HYDRA_BOOTANIMATION_FILE
COTA_SHARED_HYDRA_BOOTANIMATION_FILE_LOWERCASE=/data/shared/cust/$HYDRA_BOOTANIMATION_FILE_LOWERCASE

if [ -f $COTA_SHARED_BOOTANIMATION_FILE ]; then
    rm -f $COTA_SHARED_BOOTANIMATION_FILE
    echo "Delete bootanimation.zip from shared file"
fi

if [ -f $COTA_SHARED_BOOTANIMATION_SOUND_FILE ]; then
    rm -f $COTA_SHARED_BOOTANIMATION_SOUND_FILE
    echo "Delete PowerOn  from shared file"
fi


if [ -f $COTA_BOOTANIMATION_FILE ]; then
    rm -f $COTA_BOOTANIMATION_FILE
    echo "Delete bootanimation.zip file"
fi

if [ -f $COTA_BOOTANIMATION_SOUND_FILE ]; then
    rm -f $COTA_BOOTANIMATION_SOUND_FILE
    echo "Delete PowerOn file"
fi

if [ -f $COTA_SHUTDOWNANIMATION_FILE ]; then
    rm -f $COTA_SHUTDOWNANIMATION_FILE
    echo "Delete shutdownanimation.zip file"
fi

if [ -f $COTA_SHUTDOWNANIMATION_SOUND_FILE ]; then
    rm -f $COTA_SHUTDOWNANIMATION_SOUND_FILE
    echo "Delete PowerOff file"
fi

if [ -f $COTA_HYDRA_BOOTANIMATION_FILE ]; then
    rm -f $COTA_HYDRA_BOOTANIMATION_FILE
    echo "Delete Hydra animation file"
fi

if [ -f $COTA_HYDRA_BOOTANIMATION_FILE_LOWERCASE ]; then
    rm -f $COTA_HYDRA_BOOTANIMATION_FILE_LOWERCASE
    echo "Delete Hydra animation file"
fi

if [ -f $COTA_SHARED_HYDRA_BOOTANIMATION_FILE ]; then
    rm -f $COTA_SHARED_HYDRA_BOOTANIMATION_FILE
    echo "Delete Hydra animation file"
fi

if [ -f $COTA_SHARED_HYDRA_BOOTANIMATION_FILE_LOWERCASE ]; then
    rm -f $COTA_SHARED_HYDRA_BOOTANIMATION_FILE_LOWERCASE
    echo "Delete Hydra animation file"
fi

if [ "$SMARTCA_UNDO_FLAG" == "1" ]; then
    # set 2 to distinguish undo task done
    /product/bin/laop_cmd setprop persist.vendor.lge.smartca.undo 2
    exit 0
fi
