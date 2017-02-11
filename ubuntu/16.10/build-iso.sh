#!/bin/bash
set -e

# get parameters
IMAGE_TYPE=${1:-"netboot"}
SOURCE_ISO_URL=""

case "$IMAGE_TYPE" in
  netboot)
    SOURCE_ISO_URL="http://archive.ubuntu.com/ubuntu/dists/yakkety/main/installer-amd64/current/images/netboot/mini.iso"
    ;;
  server)
    SOURCE_ISO_URL="http://releases.ubuntu.com/16.10/ubuntu-16.10-server-amd64.iso"
    ;;
  *)
    echo "Usage: $0 <image-type> <target-iso>"
    echo "Note: valid image types are 'netboot' (default) and 'server'"
    exit 1
esac

TARGET_ISO=${2:-"`pwd`/ubuntu-16.10-$IMAGE_TYPE-amd64-unattended.iso"}

echo "IMAGE_TYPE=$IMAGE_TYPE"
echo "SOURCE_ISO_URL=$SOURCE_ISO_URL"
echo "TARGET_ISO=$TARGET_ISO"
exit 0

# get all directories
CURRENT_DIR="`pwd`"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TMP_DOWNLOAD_DIR="`mktemp -d`"
TMP_DISC_DIR="`mktemp -d`"
TMP_INITRD_DIR="`mktemp -d`"

# go back to initial directory
cd "$CURRENT_DIR"

# delete all temporary directories
rm -r "$TMP_DOWNLOAD_DIR"
rm -r "$TMP_DISC_DIR"
rm -r "$TMP_INITRD_DIR"
