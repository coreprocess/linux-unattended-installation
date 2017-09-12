# Linux Unattended Installation

This project provides all you need to create an unattended installation of a minimal setup of Linux, whereas *minimal* translates to the most lightweight setup - including an OpenSSH service and Python - which you can derive from the standard installer of a Linux distribution. The idea is, you will do all further deployment of your configurations and services with the help of Ansible or similar tools once you completed the minimal setup.

## Ubuntu 16.04 LTS, 16.10 and 17.04

Use the `build-iso.sh` script to create an ISO file based on the netsetup image of Ubuntu.

Use the `build-disk.sh` script to create a cloneable preinstalled disk image based on the output of `build-iso.sh`.

### Prerequisites

Run `sudo apt-get install p7zip-full cpio gzip genisoimage whois pwgen wget fakeroot` to install software tools required by the `build-iso.sh` script.

Run `sudo apt-get install qemu-utils qemu-kvm` in addition to install software tools required by the `build-disk.sh` script.

### Usage

#### build-iso.sh

You can run the `build-iso.sh` script as regular user. No root permissions required.

```sh
./ubuntu/<VERSION>/build-iso.sh <ssh-public-key-file> <target-iso-file>
```

All parameters are optional.

| Parameter | Description | Default Value |
| :--- | :--- | :--- |
| `<ssh-public-key-file>` | The ssh public key to be placed in authorized_keys | `$HOME/.ssh/id_rsa.pub` |
| `<target-iso-file>` | The path of the ISO image created by this script | `ubuntu-<VERSION>-netboot-amd64-unattended.iso` |

Boot the created ISO image on the target VM or physical machine. Be aware the setup will start within 10 seconds automatically and will reset the disk of the target device completely. The setup tries to eject the ISO/CD during its final stage. It usually works on physical machines, and it works on VirtualBox. It might not function in KVM environments in case the managing environment is not aware of the *eject event*. In that case, you have to detach the ISO image manually to prevent an unintended reinstall.

Power-on the machine and log into it as root using your ssh key. The ssh host key will be generated on first boot.

#### build-disk.sh

You can run the `build-disk.sh` script as regular user. No root permissions required, if you are able to run `kvm` within your user.

```sh
./ubuntu/<VERSION>/build-disk.sh <ram-size> <disk-size> <disk-format> <ssh-public-key-file> <disk-file>
```

All parameters are optional.

| Parameter | Description | Default Value |
| :--- | :--- | :--- |
| `<ram-size>` | The RAM size used during setup routine in MB (might affect size of swap partition) | `2048` |
| `<disk-size>` | The disk size of the disk image file to be created | `10G` |
| `<disk-format>` | The format of the disk image file to be created (qcow2 or raw) | `qcow2` |
| `<ssh-public-key-file>` | The ssh public key to be placed in authorized_keys | `$HOME/.ssh/id_rsa.pub` |
| `<disk-file>` | The path of the disk image created by this script | `ubuntu-<VERSION>-amd64-<ram-size>-<disk-size>.<disk-format>` |

Use the generated disk image as stock image. Do not boot the stock image itself, since the ssh host key will be generated on first boot.
