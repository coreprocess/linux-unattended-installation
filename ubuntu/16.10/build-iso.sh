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

# get all directories
CURRENT_DIR="`pwd`"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TMP_DOWNLOAD_DIR="`mktemp -d`"
TMP_DISC_DIR="`mktemp -d`"
TMP_INITRD_DIR="`mktemp -d`"

# download and extract source iso
wget "$SOURCE_ISO_URL" -O "$TMP_DOWNLOAD_DIR/source.iso"
7z x "$TMP_DOWNLOAD_DIR/source.iso" "-o$TMP_DISC_DIR"

# patch boot menu
cd "$TMP_DISC_DIR"
patch -p1 -i "$SCRIPT_DIR/boot-menu.patch"

# append preseed.cfg to initrd
cd "$SCRIPT_DIR"
cat "$TMP_DISC_DIR/initrd.gz" | gzip -d > "$TMP_INITRD_DIR/initrd"
echo "preseed.cfg" | cpio -o -H newc -A -F "$TMP_INITRD_DIR/initrd"
cat "$TMP_INITRD_DIR/initrd" | gzip -9c > "$TMP_DISC_DIR/initrd.gz"

# build iso
cd "$TMP_DISC_DIR"
rm -r '[BOOT]'
mkisofs -r -V "Ubuntu 16.10 Unattended" -cache-inodes -J -l -b isolinux.bin -c boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -input-charset utf-8 -o "$TARGET_ISO" ./

# go back to initial directory
cd "$CURRENT_DIR"

# delete all temporary directories
rm -r "$TMP_DOWNLOAD_DIR"
rm -r "$TMP_DISC_DIR"
rm -r "$TMP_INITRD_DIR"
