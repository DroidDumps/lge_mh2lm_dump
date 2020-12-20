#!/vendor/bin/sh
BOOT_PRODUCT_DEVICE=`getprop ro.boot.vendor.lge.product.device`
BOOT_PRODUCT_NAME=`getprop ro.boot.vendor.lge.product.name`
BOOT_PRODUCT_MODEL=`getprop ro.boot.vendor.lge.product.model`

#VENDOR_PRODUCT_DEVICE=$(echo $(grep -w ro.product.vendor.device /vendor/build.prop) | sed -e 's/ro.product.vendor.device=//;s/^[ \t]*//;s/[ \t].*//')
#VENDOR_PRODUCT_NAME=$(echo $(grep -w ro.product.vendor.name /vendor/build.prop) | sed -e 's/ro.product.vendor.name=//;s/^[ \t]*//;s/[ \t].*//')
#VENDOR_PRODUCT_MODEL=$(echo $(grep -w ro.product.vendor.model /vendor/build.prop) | sed -e 's/ro.product.vendor.model=//;s/^[ \t]*//;s/[ \t].*//')
#VENDOR_FINGERPRINT=$(echo $(grep -w ro.vendor.build.fingerprint /vendor/build.prop) | sed -e 's/ro.vendor.build.fingerprint=//;s/^[ \t]*//;s/[ \t].*//')
#PRODUCT_FINGERPRINT=$(echo $(grep -w ro.product.build.fingerprint /product/build.prop) | sed -e 's/ro.product.build.fingerprint=//;s/^[ \t]*//;s/[ \t].*//')

VENDOR_PRODUCT_DEVICE=$(echo $(sed -nE 's/^ro.product.vendor.device=(.+)/\1/p' /vendor/build.prop | sed -e 's/^[ \t]*//;s/[ \t].*//'))
VENDOR_PRODUCT_NAME=$(echo $(sed -nE 's/^ro.product.vendor.name=(.+)/\1/p' /vendor/build.prop | sed -e 's/^[ \t]*//;s/[ \t].*//'))
VENDOR_PRODUCT_MODEL=$(echo $(sed -nE 's/^ro.product.vendor.model=(.+)/\1/p' /vendor/build.prop | sed -e 's/^[ \t]*//;s/[ \t].*//'))
VENDOR_FINGERPRINT=$(echo $(sed -nE 's/^ro.vendor.build.fingerprint=(.+)/\1/p' /vendor/build.prop | sed -e 's/^[ \t]*//;s/[ \t].*//'))
PRODUCT_FINGERPRINT=$(echo $(sed -nE 's/^ro.product.build.fingerprint=(.+)/\1/p' /product/build.prop | sed -e 's/^[ \t]*//;s/[ \t].*//'))

# For Device Name Variants Set
if [ "${VENDOR_PRODUCT_DEVICE}" != "" ] && [ "${BOOT_PRODUCT_DEVICE}" != "" ]; then
    setprop ro.vendor.lge.product.device ${BOOT_PRODUCT_DEVICE}
    VENDOR_FINGERPRINT=$(echo ${VENDOR_FINGERPRINT} | sed -r "s/${VENDOR_PRODUCT_DEVICE}:/${BOOT_PRODUCT_DEVICE}:/")
fi

# For Product Name Variants Set
if [ "${VENDOR_PRODUCT_NAME}" != "" ] && [ "${BOOT_PRODUCT_NAME}" != "" ]; then
    setprop ro.vendor.lge.product.name ${BOOT_PRODUCT_NAME}
    VENDOR_FINGERPRINT=$(echo ${VENDOR_FINGERPRINT} | sed -r "s/${VENDOR_PRODUCT_NAME}\//${BOOT_PRODUCT_NAME}\//")
fi

# For Product Model Variants Set
if [ "${VENDOR_PRODUCT_MODEL}" != "" ] && [ "${BOOT_PRODUCT_MODEL}" != "" ]; then
    setprop ro.vendor.lge.product.model ${BOOT_PRODUCT_MODEL}
fi

if [ "${VENDOR_FINGERPRINT}" != "" ] ; then
    setprop ro.vendor.lge.build.fingerprint ${VENDOR_FINGERPRINT}
    if [ "${PRODUCT_FINGERPRINT}" != "" ]; then
        setprop ro.vendor.lge.product.build.fingerprint ${VENDOR_FINGERPRINT}
    fi
fi

exit 0
