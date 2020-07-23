#!/usr/bin/env bash
set -euo pipefail

readonly VERSION=${1:-18.04}
exec /ubuntu/${VERSION}/build-iso.sh "$HOME/.ssh/id_rsa.pub" "/iso/ubuntu-${VERSION}-netboot-amd64-unattended.iso"
