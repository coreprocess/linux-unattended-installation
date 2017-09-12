#!/bin/bash
set -e

# get parameters
SSH_PUBLIC_KEY_FILE=${1:-"$HOME/.ssh/id_rsa.pub"}
TARGET_ISO=${2:-"`pwd`/ubuntu-17.04-netboot-amd64-unattended.iso"}

# read ssh public key
if [ ! -f "$SSH_PUBLIC_KEY_FILE" ];
then
    echo "Error: public SSH key $SSH_PUBLIC_KEY_FILE not found!"
    exit 1
fi

SSH_PUBLIC_KEY="`cat "$SSH_PUBLIC_KEY_FILE"`"

# get directories
CURRENT_DIR="`pwd`"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TMP_DOWNLOAD_DIR="`mktemp -d`"
TMP_DISC_DIR="`mktemp -d`"
TMP_INITRD_DIR="`mktemp -d`"

# download and extract netboot iso
SOURCE_ISO_URL="http://archive.ubuntu.com/ubuntu/dists/zesty/main/installer-amd64/current/images/netboot/mini.iso"
wget -4 "$SOURCE_ISO_URL" -O "$TMP_DOWNLOAD_DIR/netboot.iso"
7z x "$TMP_DOWNLOAD_DIR/netboot.iso" "-o$TMP_DISC_DIR"

# patch boot menu
cd "$TMP_DISC_DIR"
patch -p1 -i "$SCRIPT_DIR/boot-menu.patch"

# prepare preseed.cfg
# ... disable root password
cp "$SCRIPT_DIR/preseed.cfg" "$TMP_INITRD_DIR/preseed.cfg"
sed -i "s/#d-i passwd\\/root-password-crypted password.*/d-i passwd\\/root-password-crypted password !/g" "$TMP_INITRD_DIR/preseed.cfg"
# ... apply authorized keys
SSH_PUBLIC_KEY_SAFE=$(printf '%s\n' "$SSH_PUBLIC_KEY" | sed 's/[[\.*/]/\\&/g; s/$$/\\&/; s/^^/\\&/')
sed -i "s/###_SSH_AUTHORIZED_KEYS_###/$SSH_PUBLIC_KEY_SAFE/g" "$TMP_INITRD_DIR/preseed.cfg"

# append preseed.cfg to initrd
cd "$TMP_INITRD_DIR"
cat "$TMP_DISC_DIR/initrd.gz" | gzip -d > "$TMP_INITRD_DIR/initrd"
echo "preseed.cfg" | cpio -o -H newc -A -F "$TMP_INITRD_DIR/initrd"
cat "$TMP_INITRD_DIR/initrd" | gzip -9c > "$TMP_DISC_DIR/initrd.gz"

# build iso
cd "$TMP_DISC_DIR"
rm -r '[BOOT]'
mkisofs -r -V "ubuntu 17.04 netboot unattended" -cache-inodes -J -l -b isolinux.bin -c boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -input-charset utf-8 -o "$TARGET_ISO" ./

# go back to initial directory
cd "$CURRENT_DIR"

# delete all temporary directories
rm -r "$TMP_DOWNLOAD_DIR"
rm -r "$TMP_DISC_DIR"
rm -r "$TMP_INITRD_DIR"

# done
echo "Next steps: install system, login via root, adjust the authorized keys, set a root password (if you want to), deploy via ansible (if applicable), enjoy!"
