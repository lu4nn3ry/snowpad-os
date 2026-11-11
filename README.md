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
+-------------------------------------------------------------+
|                 SYSTEM INITIALIZATION (PID 1)               |
|  /sbin/launchd Mach-O supervisory daemon                    |
|  Signal handling, process management, /dev/console routing  |
+-------------------------------------------------------------+
|               KERNEL & DRIVERS (Apple Darwin / XNU)         |
|  Nawcom Legacy Atom Kernel (xnu-1504 / Darwin 10.8.0)       |
|  Essential Kernel Extensions stack (/Extra/Extensions)      |
+-------------------------------------------------------------+
|                     STORAGE & BOOTSTRAP                     |
|  /dev/sda1 (279 GB Apple HFS+ Journaled, Entire Internal HDD|
|  GRUB embedded core (hfsplus / xnu) + Chameleon Bootloader  |
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
| **Ethernet** | Qualcomm Atheros AR8132 Fast Ethernet | `AtherosL1cEthernet` (`1969:1062`) |
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

## Dynamic Linker and System Runtime Compilation

The Darwin userland executes native Mach-O 64-bit binaries dynamically linked against:
- `/usr/lib/dyld` (Dynamic Linker, Mach-O type `MH_DYLINKER` `0x07`, base `0x7fff5fc00000`).
- `/usr/lib/libSystem.B.dylib` (System C Runtime, Mach-O type `MH_DYLIB`).

Both components were compiled directly from open-source code using Clang 17 and `ld64.lld` with `MacOSX.sdk`:
- `dyld`: Built from `apple-oss-distributions/dyld` (tag `dyld-132.13`), with freestanding Darwin syscall and Mach trap stubs.
- `libSystem`: Built from freestanding Darwin system call bridges implementing POSIX lifecycle, file descriptors, memory management, signals, and formatting routines.

---

## Documentation

Detailed technical documentation and development guides:

* [Darwin Architecture Specification](docs/DARWIN_ARCHITECTURE.md): Deep dive into CPUID patches, LAPIC fixes, kernel extensions, MBR partitioning, and memory layout.
* [Compilation and Deployment Guide](docs/COMPILATION_AND_DEPLOYMENT.md): Step-by-step instructions for cross-compiling Mach-O binaries in WSL using `xtool` and Clang 17, and deploying over SSH.

---

## Boot Workflow

When the netbook powers on without the USB drive inserted:

1. BIOS executes MBR code on `/dev/sda`.
2. GRUB core initializes with embedded `hfsplus` filesystem driver.
3. Configuration loaded directly from `(hd0,msdos1)/System/Library/CoreServices/grub/grub.cfg`.
4. Option 1 (Default): Apple XNU Mach-O kernel loaded (`/mach_kernel`), injecting `/Extra/Extensions/`.
5. Kernel launches PID 1 (`/sbin/launchd`).
6. `launchd` invokes `/Applications/SpringBoard.app/SpringBoard` on `/dev/console` and displays on the LG TV via VGA at 1360x768 @ 60 Hz.
