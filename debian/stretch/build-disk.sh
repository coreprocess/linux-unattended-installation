#!/bin/bash
set -e

# get parameters
RAM_SIZE=${1:-"2048"}
DISK_SIZE=${2:-"10G"}
DISK_FORMAT=${3:-"qcow2"}
SSH_PUBLIC_KEY_FILE=${4:-"$HOME/.ssh/id_rsa.pub"}
DISK_FILE=${5:-"`pwd`/debian-stretch-amd64-$RAM_SIZE-$DISK_SIZE.$DISK_FORMAT"}

# create iso
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TMP_ISO_DIR="`mktemp -d`"
eval "$SCRIPT_DIR/build-iso.sh" "$SSH_PUBLIC_KEY_FILE" "$TMP_ISO_DIR/debian-stretch-netboot-amd64-unattended.iso"

# create image and run installer
qemu-img create "$DISK_FILE" -f "$DISK_FORMAT" "$DISK_SIZE"
kvm -m "$RAM_SIZE" -cdrom "$TMP_ISO_DIR/debian-stretch-netboot-amd64-unattended.iso" -boot once=d "$DISK_FILE"

# remove tmp
rm -r -f "$TMP_ISO_DIR"

# done
echo "Next steps: deploy image, login via root, adjust the authorized keys, set a root password (if you want to), deploy via ansible (if applicable), enjoy!"
