#!/bin/bash

# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)

if [ "$EUID" -ne 0 ]; then
  echo "This script requires sudo privileges to dd to disk. Please enter your password:"
  if ! sudo -v; then
    echo "Error: Authentication failed." >&2
    exit 1
  fi
fi

BLOCK_DEV="$1"
if [ -z "$BLOCK_DEV" ]; then
  echo "Error: Missing device argument. (Usage: $0 /dev/sdX)" >&2
  exit 1
fi

if [ ! -b "$BLOCK_DEV" ] || ! sudo blockdev --getsz "$BLOCK_DEV" &>/dev/null; then
  echo "Error: Device '$BLOCK_DEV' does not exist, is ejected or is not a block device." >&2
  exit 1
fi

# Find the path of the most recently modified .img.gz file in ./target
LATEST_GZ=$(find ./target -maxdepth 1 -name "*.img.gz" -printf '%T@ %p\n' | sort -nk1 | tail -n1 | awk '{print $2}')
if [ -z "$LATEST_GZ" ]; then
  echo "Error: No .img.gz files found in ./target" >&2
  exit 1
fi

# Derive the target .img path by stripping the '.gz' extension
echo "Decompressing '$LATEST_GZ'..."
TARGET_IMG="${LATEST_GZ%.gz}"
if ! gzip -dkf "$LATEST_GZ"; then
  echo "Error: Decompression failed." >&2
  exit 1
fi

# Flash image to the partition device using dd
echo "Flashing image '$TARGET_IMG' to '$BLOCK_DEV'..."
if ! sudo dd if="$TARGET_IMG" of="$BLOCK_DEV" bs=4M conv=fsync; then
  echo "Error: Failed to write image to $BLOCK_DEV" >&2
  exit 1
fi

# Ensure all written data is physically flushed to the media
sudo sync

# Prepare mount point and mount the partition
MOUNT_PATH="./target/mount"
if ! sudo mkdir -p "$MOUNT_PATH"; then
  echo "Error: Failed to create mount directory $MOUNT_PATH" >&2
  exit 1
fi

echo "Fixing 'boot.ini'..."

if ! sudo mount "${BLOCK_DEV}1" "$MOUNT_PATH"; then
  echo "Error: Failed to mount ${BLOCK_DEV}1 to $MOUNT_PATH" >&2
  exit 1
fi

# Append newline to boot.ini if it exists
if [ -f "$MOUNT_PATH/boot.ini" ]; then
  if ! sed -i '2i\' "$MOUNT_PATH/boot.ini"; then
    echo "Error: Failed writing to $MOUNT_PATH/boot.ini" >&2
    sudo umount "$MOUNT_PATH" 2>/dev/null
    exit 1
  fi
else
  echo "Warning: boot.ini not found on the mounted partition." >&2
fi

# Flush changes and cleanly unmount
sudo sync "$MOUNT_PATH"
if ! sudo umount "$MOUNT_PATH"; then
  echo "Error: Failed to unmount $MOUNT_PATH safely." >&2
  exit 1
fi

echo "Ejecting '$BLOCK_DEV'..."
# Eject the drive safely
if ! sudo eject "$BLOCK_DEV"; then
  echo "Error: Failed to safely eject drive $BLOCK_DEV" >&2
  exit 1
fi
