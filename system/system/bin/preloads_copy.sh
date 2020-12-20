#!/system/bin/sh
#
# Copyright (C) 2016 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This script copies preloaded content from system_b to data partition

# Helper function to copy files
function do_copy_file() {
  source_file=$1
  dest_name=$2
  dest_root_folder=$3

  # Move to a temporary file so we can do a rename and have the preopted file
  # appear atomically in the filesystem.
  temp_dest_name=${dest_name}.tmp
  if ! cp -f ${source_file} ${temp_dest_name} ; then
    log -p w -t preloads_copy "Unable to copy file ${source_file} to ${temp_dest_name}!"
  else
    log -p i -t preloads_copy "Copied file from ${source_file} to ${temp_dest_name}"
    sync
    if ! mv -f ${temp_dest_name} ${dest_name} ; then
      log -p w -t preloads_copy "Unable to rename temporary file from ${temp_dest_name} to ${dest_name}"
    else
      log -p i -t preloads_copy "Renamed temporary file from ${temp_dest_name} to ${dest_name}"
      if [[ "${dest_root_folder}" == *"preload"* ]] ; then
        chown system:system ${dest_name}
        chmod 644 ${dest_name}
      elif [[ "${dest_root_folder}" == *"media"* ]] ; then
        chown media_rw:media_rw ${dest_name}
        chmod 664 ${dest_name}
      else
        log -p w -t preloads_copy "do_copy_file, Unable to find folder name ${dest_root_folder}, dest_name: ${dest_name}"
      fi
    fi
  fi
}

# Helper function to copy folder
function do_copy_folder() {
  source_folder=$1
  dest_root_folder=$2

  for file in $(find ${source_folder} -type f -name "*.*"); do
    temp_name=${file/${source_folder}/}
    dest_name=${dest_root_folder}${temp_name}

    dest_folder=$(dirname $dest_name)
    mkdir -p ${dest_folder}

    if [[ "${dest_root_folder}" == *"temp"* ]] ; then
      chown -R system:system ${dest_root_folder}
      chmod -R 755 ${dest_root_folder}
    elif [[ "${dest_root_folder}" == *"preload"* ]] ; then
      chown system:system ${dest_folder}
      chmod 755 ${dest_folder}
    elif [[ "${dest_root_folder}" == *"media"* ]] ; then
      chown media_rw:media_rw ${dest_folder}
      chmod 775 ${dest_folder}
    else
      log -p w -t preloads_copy "do_copy_folder, Unable to find folder name ${dest_root_folder}"
    fi

    #log -p i -t preloads_copy "do_copy_folder : source_folder: ${source_folder}, dest_root_folder: ${dest_root_folder}, file: ${file}"
    #log -p i -t preloads_copy "do_copy_folder : temp_name: ${temp_name}, dest_name: ${dest_name}, dest_folder: ${dest_folder}"

    # Copy files in background to speed things up
    do_copy_file ${file} ${dest_name} ${dest_root_folder} &
  done
}

OP_ROOT=`getprop ro.vendor.lge.capp_cupss.rootdir`
OP_NAME=`cat ${OP_ROOT}/totc.cfg`

FACTORY_FLAG=`getprop vendor.lge.factory.cppreloads`

if [ $# -eq 1 ]; then
  # Where the system_b is mounted that contains the preloaded files
  mountpoint=$1

  log -p i -t preloads_copy "preloads_copy from ${mountpoint}"
  log -p i -t preloads_copy "FACTORY_FLAG: ${FACTORY_FLAG}, OP_ROOT: ${OP_ROOT}, OP_NAME: ${OP_NAME}"

  if [[ "$FACTORY_FLAG" == "0" ]] ; then
    log -p i -t preloads_copy "FACTORY_FLAG is 0. exit"
    exit 0
  fi

  CACHE_DATA_DIR="/cache/data"
  DATA_PRELOAD_DIR="/data/preload"
  DATA_PRELOAD_TEMP_DIR="/data/preload/temp"
  SYSTEM_PRELOAD_DIR="/system/preload"
  DATA_MEDIA_DIR="/data/media"
  DATA_MEDIA_PRELOAD_DIR="/data/media/0/Preload"
  # All preload contents do the copy task
  # NOTE: this implementation will break in any path with spaces to favor
  # background copy tasks
  if [[ "${mountpoint}" == "${CACHE_DATA_DIR}" ]] ; then
    mkdir -p ${DATA_PRELOAD_DIR}
    chown system:system ${DATA_PRELOAD_DIR}
    chmod 755 ${DATA_PRELOAD_DIR}

    mkdir -p ${DATA_PRELOAD_TEMP_DIR}
    chown system:system ${DATA_PRELOAD_TEMP_DIR}
    chmod 775 ${DATA_PRELOAD_TEMP_DIR}

    chown system:system ${SYSTEM_PRELOAD_DIR}
    chmod 775 ${SYSTEM_PRELOAD_DIR}

    do_copy_folder ${CACHE_DATA_DIR}/preload/ ${DATA_PRELOAD_DIR}/ &
    do_copy_folder ${CACHE_DATA_DIR}/media/ ${DATA_PRELOAD_TEMP_DIR}/
  elif [[ "${mountpoint}" == "${DATA_PRELOAD_TEMP_DIR}" ]] ; then
    do_copy_folder ${DATA_PRELOAD_TEMP_DIR}/ ${DATA_MEDIA_DIR}/
    wait
    rm -rf ${DATA_PRELOAD_TEMP_DIR}
  elif [[ "${mountpoint}" == "${SYSTEM_PRELOAD_DIR}" ]] ; then
    do_copy_folder ${SYSTEM_PRELOAD_DIR}/ ${DATA_MEDIA_PRELOAD_DIR}/
    wait
  elif [[ "${mountpoint}" == *"preload"* ]] ; then
    mkdir -p ${DATA_PRELOAD_DIR}
    chown system:system ${DATA_PRELOAD_DIR}
    chmod 755 ${DATA_PRELOAD_DIR}

    if [[ "$OP_ROOT" == *"SUPERSET"* ]] ; then
      ENTRY=`ls -F ${mountpoint}`
      for item in $ENTRY
      do
        if [[ "$item" == */* ]] ; then
          do_copy_folder ${mountpoint}/${item} ${DATA_PRELOAD_DIR} &
        fi
      done
    else
      do_copy_folder ${mountpoint}/_COMMON ${DATA_PRELOAD_DIR} &

      if [ ${OP_NAME} ] ; then
        do_copy_folder ${mountpoint}/${OP_NAME} ${DATA_PRELOAD_DIR} &
      fi
    fi
    wait
  else
    do_copy_folder ${mountpoint} ${DATA_MEDIA_DIR}
  fi

  wait
  exit 0
else
  log -p e -t preloads_copy "Usage: preloads_copy <preloads-mount-point>"
  exit 1
fi
