# Linux Unattended Installation

All you need to create an unattended installation of a minimal setup of Linux, whereas 'minimal' translates to the most lightweight setup including an OpenSSH service which you can get from the standard installer of a Linux distribution.

## Ubuntu 16.10

Use the `build-iso.sh` script to create an ISO file based on the netsetup image of Ubuntu.

### Prerequisites

The following software tools are required to run the `build-iso.sh` script.

| Binary | Debian-Package |
| :--- | :--- |
| `7z` | `p7zip-full` |
| `cpio` | `cpio` |
| `gzip` | `gzip` |
| `mkisofs` | `genisoimage` |
| `mkpasswd` | `whois` |
| `pwgen` | `pwgen` |
| `wget` | `wget` |

### Usage

You can run the `build-iso.sh` script as regular user. No root permissions required.

```sh
./ubuntu/16.10/build-iso.sh <root-password> <target-iso-file>
```

| Parameter | Description | Default Value |
| :--- | :--- | :--- |
| `<root-password>` | The root password of the instances created from this ISO image | Output of `pwgen -N1 -B` |
| `<target-iso-file>` | The path of the ISO image created by this script | `ubuntu-16.10-netboot-amd64-unattended-<root-password>.iso` |
