#!/bin/sh
if [ -d /system/OP ]; then
    # If it is using bootanim at system partition, then we can skip all.
    exit 0;
fi

OPERATOR=`getprop ro.vendor.lge.build.target_operator`
COUNTRY=`getprop ro.vendor.lge.build.target_country`
BUILD_TYPE=`getprop ro.build.type`
DCOUNTRY=`/product/bin/laop_cmd getprop ro.vendor.lge.build.default_country`
UI_BASE_CA=`/product/bin/laop_cmd getprop ro.vendor.lge.build.ui_base_ca`
MCC=`/product/bin/laop_cmd getprop persist.vendor.lge.ntcode`
CUPSS_ROOT_DIR=`getprop ro.vendor.lge.capp_cupss.rootdir`
CUPSS_PROP_FILE=`/product/bin/laop_cmd getprop persist.vendor.lge.cupss.subca-prop`
CUPSS_CHANGED=`/product/bin/laop_cmd getprop persist.vendor.lge.cupss.changed`
IS_COTA_CHANGED=`/product/bin/laop_cmd getprop persist.vendor.lge.cota.changed`
IS_MULTISIM=`/product/bin/laop_cmd getprop ro.boot.vendor.lge.sim_num`
OP_INTEGRATION=`/product/bin/laop_cmd getprop ro.vendor.lge.op.integration`
OP_ROOT_PATH=`/product/bin/laop_cmd getprop ro.vendor.lge.capp_cupss.op.dir`
IS_LIVE_DEMO_UNIT=`/product/bin/laop_cmd getprop persist.vendor.lge.LiveDemoUnit`


if [ "$OP_INTEGRATION" == "1" ]; then
    CUPSS_DEFAULT_PATH=$OP_ROOT_PATH
    RES_PATH=_SMARTCA_RES
    if [ "$OP_ROOT_PATH" == "/OP" ]; then
        COTA_RES_ROOT_PATH=$CUPSS_DEFAULT_PATH
    else
        COTA_RES_ROOT_PATH=/mnt/product/carrier
    fi
else
    OP_ROOT_PATH=/OP
    CUPSS_DEFAULT_PATH=/cust
    RES_PATH=_COTA_RES
fi

MCC=${MCC#*,}
MCC=${MCC:1:3}

USER_BOOTANIMATION_FILE=/data/local/bootanimation.zip
USER_BOOTANIMATION_SOUND_FILE=/data/local/PowerOn.ogg
USER_SHUTDOWNANIMATION_FILE=/data/local/shutdownanimation.zip
USER_SHUTDOWNANIMATION_SOUND_FILE=/data/local/PowerOff.ogg
USER_APP_MANAGER_INSTALLATION_FILE=/data/local/app-ntcode-conf.json

COTA_BOOTANIMATION_FILE=${COTA_RES_ROOT_PATH}/${RES_PATH}/bootanimation.zip
COTA_BOOTANIMATION_SOUND_FILE=${COTA_RES_ROOT_PATH}/${RES_PATH}/PowerOn.ogg
COTA_SHUTDOWNANIMATION_FILE=/data/shared/cust/shutdownanimation.zip
COTA_SHUTDOWNANIMATION_SOUND_FILE=/data/shared/cust/PowerOff.ogg

if [ "${DCOUNTRY}" != "" ]; then
    if [ "${UI_BASE_CA}" != "" ]; then
        SUBCA_FILE=${UI_BASE_CA}/${DCOUNTRY}
    else
        if [ $IS_MULTISIM == "2" ]; then
            SUBCA_FILE=${OPERATOR}_${COUNTRY}_DS/${DCOUNTRY}
            if [ ! -d ${CUPSS_DEFAULT_PATH}/${SUBCA_FILE} ]; then
                SUBCA_FILE=${OPERATOR}_${COUNTRY}/${DCOUNTRY}
            fi
        elif [ $IS_MULTISIM == "3" ]; then
            SUBCA_FILE=${OPERATOR}_${COUNTRY}_TS/${DCOUNTRY}
            if [ ! -d ${CUPSS_DEFAULT_PATH}/${SUBCA_FILE} ]; then
                SUBCA_FILE=${OPERATOR}_${COUNTRY}/${DCOUNTRY}
            fi
        else
            SUBCA_FILE=${OPERATOR}_${COUNTRY}/${DCOUNTRY}
            if [ ! -d ${CUPSS_DEFAULT_PATH}/${SUBCA_FILE} ]; then
                if [ -d ${CUPSS_DEFAULT_PATH}/${OPERATOR}_${COUNTRY}_DS/${DCOUNTRY} ]; then
                    SUBCA_FILE=${OPERATOR}_${COUNTRY}_DS/${DCOUNTRY}
                fi
            fi
        fi
    fi
else
    if [ "${UI_BASE_CA}" != "" ]; then
        SUBCA_FILE=${UI_BASE_CA}
    else
        if [ $IS_MULTISIM == "2" ]; then
            SUBCA_FILE=${OPERATOR}_${COUNTRY}_DS
            if [ ! -d ${CUPSS_DEFAULT_PATH}/${SUBCA_FILE} ]; then
                SUBCA_FILE=${OPERATOR}_${COUNTRY}
            fi
        elif [ $IS_MULTISIM == "3" ]; then
            SUBCA_FILE=${OPERATOR}_${COUNTRY}_TS
            if [ ! -d ${CUPSS_DEFAULT_PATH}/${SUBCA_FILE} ]; then
                SUBCA_FILE=${OPERATOR}_${COUNTRY}
            fi
        else
            SUBCA_FILE=${OPERATOR}_${COUNTRY}
            SUBCA_FILE=${OPERATOR}_${COUNTRY}
            if [ ! -d ${CUPSS_DEFAULT_PATH}/${SUBCA_FILE} ]; then
                if [ -d ${CUPSS_DEFAULT_PATH}/${OPERATOR}_${COUNTRY}_DS ]; then
                    SUBCA_FILE=${OPERATOR}_${COUNTRY}_DS
                fi
            fi
        fi
    fi
fi

if [ ! -d ${COTA_RES_ROOT_PATH}/${RES_PATH} ]; then
    if [ $(ls /data/shared/cust/bootanimation.zip) ]; then
        if [ "$OP_INTEGRATION" == "1" ]; then
            /product/bin/laop_cmd setprop persist.vendor.lge.smartca.changed 1
        else
            /product/bin/laop_cmd setprop persist.vendor.lge.cota.changed 1
        fi
    fi
fi

if [ -d $CUPSS_ROOT_DIR ]; then
    DOWNCA_APP_MANAGER_INSTALLATION_FILE=$CUPSS_ROOT_DIR/config/app-special-conf.json
fi

if [ -d $OP_ROOT_PATH ]; then
    ANI_ROOT_PATH=$OP_ROOT_PATH
    if [ ! -f $DOWNCA_APP_MANAGER_INSTALLATION_FILE ]; then
        DOWNCA_APP_MANAGER_INSTALLATION_FILE=$OP_ROOT_PATH/_COMMON/app-enabled-conf.json
    fi
fi

chmod 755 /data/shared
chmod 755 /data/local/cust

if [ $CUPSS_ROOT_DIR == "/data/local/cust" ]; then
    if [ ! -d ${CUPSS_ROOT_DIR} ]; then
        mkdir ${CUPSS_ROOT_DIR}
        chmod 755 ${CUPSS_ROOT_DIR}
    fi

    if [ ${CUPSS_CHANGED} == "1" ]; then
        if [ ! -d ${CUPSS_ROOT_DIR}/prev ]; then
            mkdir ${CUPSS_ROOT_DIR}/prev
            chmod 755 ${CUPSS_ROOT_DIR}/prev
        fi
        mv -f ${CUPSS_ROOT_DIR}/* ${CUPSS_ROOT_DIR}/prev
    fi

    if [[ $CUPSS_PROP_FILE == *"/OPEN_COM_DS/"* ]]; then
        OPEN_PATH=${CUPSS_DEFAULT_PATH}/OPEN_COM_DS
    elif [[ $CUPSS_PROP_FILE == *"/OPEN_COM_TS/"* ]]; then
        OPEN_PATH=${CUPSS_DEFAULT_PATH}t/OPEN_COM_TS
    else
        OPEN_PATH=${CUPSS_DEFAULT_PATH}/OPEN_COM
    fi

    CUPSS_SUBCA=${CUPSS_PROP_FILE##*cust_}
    CUPSS_SUBCA=${CUPSS_SUBCA%.prop}
    CUPSS_CA=${CUPSS_SUBCA%_*}

    DIRLIST=$(ls ${OPEN_PATH})
    for DIR in ${DIRLIST}; do
        if [ -d ${OPEN_PATH}/${DIR} ]; then
            DIRNAME=${DIR#_}
            if [ -h ${CUPSS_ROOT_DIR}/${DIRNAME} ] || [ ! -d ${CUPSS_ROOT_DIR}/${DIRNAME} ]; then
                if [ -d ${OPEN_PATH}/${DIR}/${DIRNAME}_${CUPSS_SUBCA} ]; then
                    ln -sfn ${OPEN_PATH}/${DIR}/${DIRNAME}_${CUPSS_SUBCA} ${CUPSS_ROOT_DIR}/${DIRNAME}
                else
                    ln -sfn ${OPEN_PATH}/${DIR}/${DIRNAME}_${CUPSS_CA} ${CUPSS_ROOT_DIR}/${DIRNAME}
                fi
            fi
        fi
    done
fi



if [ $OPERATOR != "GLOBAL" -a $OPERATOR != "LAO" ]; then
    log -p i -t runtime_boot_res "Do Nothing."
else
    rm $USER_APP_MANAGER_INSTALLATION_FILE
    if [ -f $DOWNCA_APP_MANAGER_INSTALLATION_FILE ]; then
        ln -sf $DOWNCA_APP_MANAGER_INSTALLATION_FILE $USER_APP_MANAGER_INSTALLATION_FILE
    fi
fi

#Single CA Google submission
if [ $OPERATOR != "GLOBAL" -a $OPERATOR != "LAO" ]; then
    rm -f $USER_APP_MANAGER_INSTALLATION_FILE

    SINGLECA_ENABLE=`/product/bin/laop_cmd getprop ro.vendor.lge.singleca.enable`
    SINGLECA_SUBMIT=`/product/bin/laop_cmd getprop ro.vendor.lge.singleca.submit`

    if [ "${SINGLECA_ENABLE}" == "1" -a "${SINGLECA_SUBMIT}" == "1" ]; then
        if [ -f $DOWNCA_APP_MANAGER_INSTALLATION_FILE ]; then
            ln -sf $DOWNCA_APP_MANAGER_INSTALLATION_FILE $USER_APP_MANAGER_INSTALLATION_FILE
        fi
    fi
fi

CUST_AUDIO_PATH=${CUPSS_DEFAULT_PATH}/${SUBCA_FILE}/media/audio
CUST_RINGTONE_PATH=${CUST_AUDIO_PATH}/ringtones
CUST_NOTIFICATION_PATH=${CUST_AUDIO_PATH}/notifications
CUST_ALARM_ALERT_PATH=${CUST_AUDIO_PATH}/alarms

USER_MEDIA_PATH=/data/local/media
USER_AUDIO_PATH=/${USER_MEDIA_PATH}/audio
USER_RINGTONE_PATH=${USER_AUDIO_PATH}/ringtones
USER_NOTIFICATION_PATH=${USER_AUDIO_PATH}/notifications
USER_ALARM_ALERT_PATH=${USER_AUDIO_PATH}/alarms

rm -rf $USER_MEDIA_PATH

IS_SUBCA_EXIST=$(ls -R ${CUST_AUDIO_PATH} | grep "\_[0-9]\{3\}\.")
if [ $? -eq 0 ]; then
    mkdir -p $USER_AUDIO_PATH
    mkdir $USER_RINGTONE_PATH
    mkdir $USER_NOTIFICATION_PATH
    mkdir $USER_ALARM_ALERT_PATH
    chmod 755 $USER_MEDIA_PATH
    chmod 755 -R $USER_MEDIA_PATH/*
    SAVEIFS=$IFS
    IFS=$(echo -en "\n\b")
    if [ -d ${CUST_RINGTONE_PATH} ]; then
        if [ ! $(ls ${CUPSS_DEFAULT_PATH}/${SUBCA_FILE}/config/noringtone.open) ]; then
        CUST_RINGTONE_FILES=$(ls ${CUST_RINGTONE_PATH} | grep ${MCC})
        if [ $? -eq 0 ]; then
            for CUST_RINGTONE_FILE in ${CUST_RINGTONE_FILES}; do
                    RINGTONE_EXTENTION=${CUST_RINGTONE_FILE##*.}
                    RINGTONE_FILE_NAME=${CUST_RINGTONE_FILE%%_${MCC}*}
                    cp -p ${CUST_RINGTONE_PATH}/${CUST_RINGTONE_FILE} ${USER_RINGTONE_PATH}/${RINGTONE_FILE_NAME}.${RINGTONE_EXTENTION}
            done
        else
            RINGTONE_FILES=$(ls ${CUST_RINGTONE_PATH} | grep -v "\_[0-9]\{3\}\.")
            if [ $? -eq 0 ]; then
                for RINGTONE_FILE in ${RINGTONE_FILES}; do
                    cp -p ${CUST_RINGTONE_PATH}/${RINGTONE_FILE} ${USER_RINGTONE_PATH}/${RINGTONE_FILE}
                done
            fi
        fi
    fi
    fi
    if [ -d ${CUST_NOTIFICATION_PATH} ]; then
        if [ ! $(ls ${CUPSS_DEFAULT_PATH}/${SUBCA_FILE}/config/nonotification.open) ]; then
        CUST_NOTIFICATION_FILES=$(ls ${CUST_NOTIFICATION_PATH} | grep ${MCC})
        if [ $? -eq 0 ]; then
            for CUST_NOTIFICATION_FILE in ${CUST_NOTIFICATION_FILES}; do
                    NOTIFICATION_EXTENTION=${CUST_NOTIFICATION_FILE##*.}
                    NOTIFICATION_FILE_NAME=${CUST_NOTIFICATION_FILE%%_${MCC}*}
                    cp -p ${CUST_NOTIFICATION_PATH}/${CUST_NOTIFICATION_FILE} ${USER_NOTIFICATION_PATH}/${NOTIFICATION_FILE_NAME}.${NOTIFICATION_EXTENTION}
            done
        else
            NOTIFICATION_FILES=$(ls ${CUST_NOTIFICATION_PATH} | grep -v "\_[0-9]\{3\}\.")
            if [ $? -eq 0 ]; then
                for NOTIFICATION_FILE in ${NOTIFICATION_FILES}; do
                    cp -p ${CUST_NOTIFICATION_PATH}/${NOTIFICATION_FILE} ${USER_NOTIFICATION_PATH}/${NOTIFICATION_FILE}
                done
            fi
        fi
        fi
    fi
    if [ -d ${CUST_ALARM_ALERT_PATH} ]; then
        if [ ! $(ls ${CUPSS_DEFAULT_PATH}/${SUBCA_FILE}/config/noalarm.open) ]; then
        CUST_ALARM_ALERT_FILES=$(ls ${CUST_ALARM_ALERT_PATH} | grep ${MCC})
        if [ $? -eq 0 ]; then
            for CUST_ALARM_ALERT_FILE in ${CUST_ALARM_ALERT_FILES}; do
                    ALARM_ALERT_EXTENTION=${CUST_ALARM_ALERT_FILE##*.}
                    ALARM_ALERT_FILE_NAME=${CUST_ALARM_ALERT_FILE%%_${MCC}*}
                    cp -p ${CUST_ALARM_ALERT_PATH}/${CUST_ALARM_ALERT_FILE} ${USER_ALARM_ALERT_PATH}/${ALARM_ALERT_FILE_NAME}.${ALARM_ALERT_EXTENTION}
            done
        else
            ALARM_ALERT_FILES=$(ls ${CUST_ALARM_ALERT_PATH} | grep -v "\_[0-9]\{3\}\.")
            if [ $? -eq 0 ]; then
                for ALARM_ALERT_FILE in ${ALARM_ALERT_FILES}; do
                    cp -p ${CUST_ALARM_ALERT_PATH}/${ALARM_ALERT_FILE} ${USER_ALARM_ALERT_PATH}/${ALARM_ALERT_FILE}
                done
            fi
        fi
        fi
    fi
    IFS=$SAVEIFS
fi

/product/bin/laop_cmd setprop persist.vendor.lge.ntcode_list 1

exit 0
