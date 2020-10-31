# Linux Unattended Installation

This project provides all you need to create an unattended installation of a minimal setup of Linux, whereas *minimal* translates to the most lightweight setup - including an OpenSSH service and Python - which you can derive from the standard installer of a Linux distribution. The idea is, you will do all further deployment of your configurations and services with the help of Ansible or similar tools once you completed the minimal setup.

## Ubuntu 16.04 LTS and 18.04 LTS

Use the `build-iso.sh` script to create an ISO file based on the netsetup image of Ubuntu.

Use the `build-disk.sh` script to create a cloneable preinstalled disk image based on the output of `build-iso.sh`.

### Features

* Fully automated installation procedure.
* Shutdown and power off when finished. We consider this a feature since it produces a defined and detectable state once the setup is complete.
* Authentication based on SSH public key and not on a password.
* Setup ensures about 25% of free disk space in the LVM group. We consider this a feature since it enables you to use LVM snapshots; e.g., for backup purposes.
* Generates SSH server keys on first boot and not during setup stage. We consider this a feature since it enables you to use the installed image as a template for multiple machines.
* Prints IPv4 and IPv6 address of the device on screen once booted.
* USB bootable hybrid ISO image.
* UEFI and BIOS mode supported.

### Prerequisites

#### Linux

Run `sudo apt-get install dos2unix p7zip-full cpio gzip genisoimage whois pwgen wget fakeroot isolinux xorriso` to install software tools required by the `build-iso.sh` script.

Run `sudo apt-get install qemu-utils qemu-kvm` in addition to install software tools required by the `build-disk.sh` script.

#### Mac (Ubuntu 18.04 LTS only)

Run `brew install p7zip xorriso wget dos2unix fakeroot coreprocess/gnucpio/gnucpio` to install software tools required by the `build-iso.sh` script.

The script `build-disk.sh` is not supported on Mac.

#### Docker

Run `docker build -t ubuntu-unattended .` to build the Docker image.

When running the Docker container, add the public key you want to use and the ISO output directory as volume links and specify the desired Ubuntu version as parameter (defaults to 18.04), e.g:

```sh
docker run \
  --rm \
  -t \
  -v "$HOME/.ssh/id_rsa.pub:/root/.ssh/id_rsa.pub:ro" \
  -v "$(pwd):/iso" \
  ubuntu-unattended \
  16.04
```

Explanation of the command switches:
```sh
--rm
# Remove the Docker container when finished

-t
# Show terminal output

-v "$HOME/.ssh/id_rsa.pub:/root/.ssh/id_rsa.pub:ro"
# Mount "$HOME/.ssh/id_rsa.pub" from your machine to "/root/.ssh/id_rsa.pub"
# in the container (read only).
# This is the path, where the script expects your public key to be.

-v "$(pwd):/iso"
# Mount the current working directory from your machine to "/iso"
# in the container. This is the path, where the ISO file is written to.
```

It is enough to build the container once. If you want to add a custom preseed config when executing `docker run`, mount your local copy of the file into the container, e.g: `-v "$(pwd)/my_preseed.cfg:/ubuntu/<version>/custom/preseed.cfg`.

The script `build-disk.sh` is not supported on Docker.

### Usage

#### Build ISO images

You can run the `build-iso.sh` script as regular user. No root permissions required.

```sh
./ubuntu/<VERSION>/build-iso.sh <ssh-public-key-file> <target-iso-file>
```

All parameters are optional.

| Parameter | Description | Default Value |
| :--- | :--- | :--- |
| `<ssh-public-key-file>` | The ssh public key to be placed in authorized_keys | `$HOME/.ssh/id_rsa.pub` |
| `<target-iso-file>` | The path of the ISO image created by this script | `ubuntu-<VERSION>-netboot-amd64-unattended.iso` |

Boot the created ISO image on the target VM or physical machine. Be aware the setup will start within 10 seconds automatically and will reset the disk of the target device completely. The setup tries to eject the ISO/CD during its final stage. It usually works on physical machines, and it works on VirtualBox. It might not function in certain KVM environments in case the managing environment is not aware of the *eject event*. In that case, you have to detach the ISO image manually to prevent an unintended reinstall.

Power-on the machine and log into it as root using your ssh key. The ssh host key will be generated on first boot.

#### Build disk images

You can run the `build-disk.sh` script as regular user. No root permissions required, if you are able to run `kvm` with your user account.

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

Use the generated disk image as template image and create copies of it to deploy virtual or physical machines. Do not boot the template itself, since the ssh host key will be generated on first boot.
