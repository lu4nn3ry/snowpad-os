# SnowPad OS (snowpad-os)

Pure Apple Darwin operating system running the Apple XNU kernel and Mach-O SpringBoard userland natively on Intel Atom N450 hardware.

---

## Project Overview

SnowPad OS is a bare-metal implementation of Apple Darwin (XNU 1504 / macOS Snow Leopard 10.6.8 base) with a touch-and-gamepad-driven SpringBoard userland. The internal SATA hard drive is dedicated entirely to Apple Darwin on an HFS+ Journaled filesystem (`/dev/sda1`), completely omitting Linux from the internal storage. Diagnostic, maintenance, and recovery operations (including wireless SSH control) are isolated exclusively to a bootable USB pendrive.

The system drives an external LG TV monitor via VGA at native 1360x768 @ 60 Hz on an Itautec Infoway W7020 netbook (Intel Atom N450 @ 1.66 GHz, 2 GB DDR2 RAM, Intel GMA 3150).

---

## Architecture

```text
+-------------------------------------------------------------+
|        USERLAND EXPERIENCE (SpringBoard / Touch Hub)        |
|  SpringBoard.app (Home Screen, Grid Icons, Glowing Focus)   |
|  Native Mach-O 64-bit Binaries compiled via xtool / Clang   |
|  Microntek USB Gamepad Navigation (D-Pad, Analog, Buttons)  |
+-------------------------------------------------------------+
|                     DYNAMIC RUNTIME LAYER                   |
|  /usr/lib/dyld (Apple Open Source dyld-132.13, MH_DYLINKER) |
|  /usr/lib/libSystem.B.dylib (Mach-O direct XNU syscalls)    |
|  PureDarwin System.framework, IOKit.framework, libc         |
+-------------------------------------------------------------+
|                 SYSTEM INITIALIZATION (PID 1)               |
|  /sbin/launchd Mach-O supervisory script                    |
|  /sbin/netsetup network interface & routing initializer     |
|  /usr/sbin/dropbear native Darwin SSH daemon on port 22     |
+-------------------------------------------------------------+
|               KERNEL & DRIVERS (Apple Darwin / XNU)         |
|  Nawcom Legacy Atom Kernel (xnu-1504 / Darwin 10.8.0)       |
|  Atheros AR8132 Ethernet (AtherosL1cEthernet.kext)         |
|  Smartphone USB Tethering (HoRNDIS.kext)                   |
|  Essential Kernel Extensions stack (/Extra/Extensions)      |
+-------------------------------------------------------------+
|                     STORAGE & BOOTSTRAP                     |
|  /dev/sda1 (279 GB Apple HFS+ Journaled, Entire Internal HDD)|
|  Chameleon 2.0 RC4 Bootloader (MBR boot0 + PBR boot1h + /boot)|
+-------------------------------------------------------------+
```

---

## Hardware Specifications and Driver Matrix

| Component | Specification | Driver / Subsystem |
|---|---|---|
| **CPU** | Intel Atom N450 (1C/2T @ 1.66 GHz) | Nawcom Legacy XNU Kernel (`mach_kernel`) |
| **GPU** | Intel GMA 3150 (Pineview 256-bit) | VESA Framebuffer / VGA 1360x768 @ 60 Hz |
| **RAM** | 2048 MB DDR2 667 MHz | Mach Virtual Memory Subsystem |
| **Storage** | 320 GB Internal SATA HDD | Dedicated Partition `/dev/sda1` (279 GB Apple HFS+) |
| **Audio** | Realtek ALC272 HDA | `VoodooHDA.kext` / `AppleALC.kext` |
| **Network (Tethering)** | Android / iPhone USB Tethering | `HoRNDIS.kext` (Instant Wi-Fi / 4G / 5G gateway) |
| **Ethernet** | Qualcomm Atheros AR8132 Fast Ethernet | `AtherosL1cEthernet.kext` (`1969:1062`) |
| **Wireless LAN** | Realtek RTL8192SE / RTL8191SE PCIe | No native PCIe kext; routed via AR8132 or HoRNDIS |
| **Keyboard / Trackpad** | Synaptics PS/2 Touchpad + Matrix Keyb | `VoodooPS2Controller.kext` + `AppleACPIPS2Nub.kext` |
| **Power Management** | ACPI / HPET Override | `NullCPUPowerManagement.kext` + `SleepEnabler.kext` |
| **ACPI / PCI Trees** | Pineview ACPI DSDT Tables | `EvilAppleACPIPlatform.kext` + `EvilIOPCIFamily.kext` |
| **System Management** | SMC Emulation | `FakeSMC.kext` / `VirtualSMC.kext` |

---

## Internal Storage vs Maintenance Strategy

1. **Internal Hard Drive (`/dev/sda`)**:
   - Single dedicated partition: `/dev/sda1` (279 GB Apple HFS+ Journaled, Type `0xAF`).
   - Linux rootfs completely removed from internal storage.
   - Master Boot Record embeds GRUB core with native `part_msdos`, `hfsplus`, and `xnu` modules reading `/System/Library/CoreServices/grub/grub.cfg` directly from HFS+.
   - Chameleon bootloader available at `/boot` with `/Extra/DSDT.aml` and `/Extra/smbios.plist` (MacBookAir3,1 profile).

2. **Removable USB Maintenance Drive (`/dev/sdb`)**:
   - Bootable Alpine Linux live environment with persistent overlay (`itautec.apkovl.tar.gz`).
   - Automatically initializes Realtek RTL8192SE wireless module and authenticates to `LNET`.
   - Runs OpenSSH daemon with authorized public keys for remote maintenance and deployment.

---

## Standalone Darwin SSH Server and Network Stack

Darwin on `/dev/sda1` operates independently with its own native SSH daemon and network configuration:

1. **Network Initialization (`/sbin/netsetup`)**:
   - Native Mach-O 64-bit utility compiled from C using standard BSD socket ioctls (`SIOCSIFFLAGS`, `SIOCSIFADDR`, `SIOCSIFNETMASK`).
   - Automatically initializes `lo0` (127.0.0.1) and brings up physical network adapters:
     - `en0` (Atheros AR8132 Fast Ethernet) configured at `192.168.0.70/24`.
     - `en1` (HoRNDIS Smartphone USB Tethering) configured at `192.168.0.71/24`.
   - Populates `/etc/resolv.conf` with primary DNS nameservers (`192.168.0.1`, `1.1.1.1`, `8.8.8.8`).

2. **Native Darwin Dropbear SSH Daemon (`/usr/sbin/dropbear`)**:
   - Compiled from open-source Dropbear source code using `clang-17` and `ld64.lld` targeted for `x86_64-apple-darwin`.
   - Linked directly to `/usr/lib/libSystem.B.dylib` with zero external dependencies (no PAM, no external OpenSSL).
   - Generates host keys automatically into `/etc/dropbear/`.
   - Pre-configured with authorized ED25519 public keys in `/var/root/.ssh/authorized_keys`.
   - Accessible on the local network via `ssh root@192.168.0.70`.

---

## Repository Structure

```text
snowpad-os/
|-- Applications/
|   `-- SpringBoard.app/
|       |-- SpringBoard (Mach-O 64-bit executable)
|       `-- Info.plist
|-- Extra/
|   |-- DSDT.aml (Pineview ACPI table)
|   |-- smbios.plist (MacBookAir3,1 profile)
|   `-- Extensions/ (KEXT driver stack)
|       |-- AtherosL1cEthernet.kext (Atheros AR8132)
|       |-- HoRNDIS.kext (USB Smartphone Tethering)
|       |-- FakeSMC.kext
|       |-- NullCPUPowerManagement.kext
|       |-- EvilAppleACPIPlatform.kext
|       |-- EvilIOPCIFamily.kext
|       |-- VoodooHDA.kext
|       `-- VoodooPS2Controller.kext
|-- docs/
|   |-- DARWIN_ARCHITECTURE.md
|   |-- COMPILATION_AND_DEPLOYMENT.md
|   `-- STANDALONE_SSH_AND_NETWORKING.md
`-- README.md
```
