# Linux Unattended Installation

This project provides all you need to create an unattended installation of a minimal setup of Linux, whereas 'minimal' translates to the most lightweight setup - including an OpenSSH service - which you can get from the standard installer of a Linux distribution. The idea is, you will do all further deployment of your configurations and services with the help of Ansible or similar tools once you completed the minimal setup.

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

Boot the created ISO image on the target VM or physical machine. Be aware the setup will start within 10 seconds automatically and will reset the disk of the target device completely. The setup tries to eject the ISO/CD once during its final stage. It usually works on physical machines, and it works on VirtualBox. It might not function in KVM environments in case the managing environment is not aware of the 'eject event' and reboots with the ISO image attached. In that case, you have to detach the ISO image manually in time to prevent an endless setup loop.
