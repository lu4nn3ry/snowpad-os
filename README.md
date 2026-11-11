# SnowPad OS (snowpad-os)

Hybrid Darwin operating system running Apple XNU kernel and iOS 3.2 SpringBoard userland natively on Intel Atom N450 hardware.

---

## Project Overview

SnowPad OS combines the underlying stability and driver model of Apple Darwin (XNU 1504 / macOS Snow Leopard 10.6.8 base) with a lightweight, touch-and-gamepad-driven SpringBoard userland. The system runs on bare metal on the Itautec Infoway W7020 netbook (Intel Atom N450 / 2GB DDR2 RAM), driving an external LG TV monitor via VGA at native 1360x768 @ 60 Hz.

---

## Architecture

```text
+-------------------------------------------------------------+
|        USERLAND EXPERIENCE (SpringBoard / Touch Hub)        |
|  SpringBoard.app (Home Screen, Grid Icons, Glowing Focus)   |
|  Native Mach-O 64-bit Binaries compiled via xtool / Clang   |
|  Microntek USB Gamepad Navigation (D-Pad, Analog, Buttons)  |
+-------------------------------------------------------------+
|                 SYSTEM INITIALIZATION (PID 1)               |
|  /sbin/launchd Mach-O supervisory daemon                    |
|  Signal handling, process management, /dev/console routing  |
+-------------------------------------------------------------+
|               KERNEL & DRIVERS (Apple Darwin / XNU)         |
|  Nawcom Legacy Atom Kernel (xnu-1504 / Darwin 10.8.0)       |
|  I/O Kit Driver Family + Extra Extensions (/Extra/Ext)      |
+-------------------------------------------------------------+
|                     HARDWARE PLATFORM                       |
|  Intel Atom N450 @ 1.66 GHz | GMA 3150 | Realtek ALC663     |
|  Realtek RTL8192SE Wireless | 320GB Internal SATA HDD       |
+-------------------------------------------------------------+
```

---

## Key Hardware Specifications

| Component | Specification | Driver / Subsystem |
|---|---|---|
| **CPU** | Intel Atom N450 (1C/2T @ 1.66 GHz) | Nawcom Legacy XNU Kernel (`mach_kernel`) |
| **GPU** | Intel GMA 3150 (Pineview 256-bit) | Framebuffer / VGA 1360x768 @ 60 Hz |
| **RAM** | 2048 MB DDR2 667 MHz | Mach Virtual Memory Subsystem |
| **Storage** | 320 GB Internal SATA HDD | Partition `/dev/sda1` (279 GB Apple HFS+) |
| **Audio** | Realtek ALC663 HDA | `VoodooHDA.kext` |
| **Wireless** | Realtek RTL8192SE 802.11b/g/n | `RTL8192se.kext` / Realtek Utility |
| **Input** | Microntek USB Gamepad + PS/2 Keyboard | `VoodooPS2Controller.kext` / Joystick API |

---

## Documentation

Detailed technical documentation and development guides:

* [Darwin Architecture Specification](docs/DARWIN_ARCHITECTURE.md): Deep dive into CPUID patches, LAPIC fixes, kernel extensions, MBR partitioning, and memory layout.
* [Compilation and Deployment Guide](docs/COMPILATION_AND_DEPLOYMENT.md): Step-by-step instructions for cross-compiling Mach-O binaries in WSL using `xtool` and Clang 17, and deploying over SSH.

---

## Boot Options

The internal hard drive MBR contains a customized GRUB loader with direct options:

1. **SnowPad OS (TV Hub, RetroArch & Apps)**: Dedicated TV console engine running directly from internal HDD (`/dev/sda2`).
2. **SnowPad Darwin (Apple XNU Kernel)**: Direct boot into Apple XNU kernel (`/mach_kernel`) on `/dev/sda1` (HFS+).
3. **Chameleon Bootloader**: Official Apple Chameleon bootloader with graphics enabler and diagnostic flags.

---

## Repository Structure

```text
snowpad-os/
|-- docs/
|   |-- DARWIN_ARCHITECTURE.md         # Technical architecture and XNU specification
|   `-- COMPILATION_AND_DEPLOYMENT.md  # Build and deployment instructions
|-- src/
|   |-- boot/                          # Chameleon bootloader, DSDT, smbios.plist
|   |-- ios_userland/                  # SpringBoard source code and app configurations
|   |-- kernel/                        # CPUID and legacy kernel configuration
|   `-- shim/                          # Input event shims
|-- README.md                          # Project documentation
`-- TODO.html                          # Interactive roadmap dashboard
```
