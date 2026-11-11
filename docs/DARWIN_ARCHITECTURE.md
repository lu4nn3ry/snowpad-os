# Darwin Architecture Specification: SnowPad OS

## Abstract

This document outlines the architectural implementation of **SnowPad OS**, a bare-metal deployment of the Apple Darwin operating system (macOS Snow Leopard 10.6.8 / XNU 1504 base) on the Itautec Infoway W7020 netbook powered by an Intel Atom N450 processor. 

The internal storage architecture is 100% dedicated to Apple Darwin (HFS+ Journaled), completely eliminating secondary host operating systems from the internal SATA drive. System rescue and network deployment capabilities are delegated to an external USB flash medium.

---

## 1. Storage Architecture and Partitioning

The internal 320 GB SATA drive (`/dev/sda`) uses a Master Boot Record (MBR) partition table with a single active primary partition:

```text
Disk /dev/sda: 320 GB (625,142,448 sectors)
+-------------------------------------------------------------+
| Sector 0: MBR (GRUB Stage 1 + Core Embedded Image)          |
+-------------------------------------------------------------+
| Sectors 1 - 2047: Reserved Gap                              |
+-------------------------------------------------------------+
| /dev/sda1 (Sectors 2048 - 587202559, 279 GB):               |
| File System: Apple HFS+ (Journaled, Case-Preserving)        |
| Partition Type: 0xAF (Apple HFS/HFS+)                       |
| Flags: Bootable (Active, 0x80)                              |
+-------------------------------------------------------------+
| Sectors 587202560 - 625142447: Unallocated / Free Space     |
+-------------------------------------------------------------+
```

### 1.1 Filesystem Hierarchy on `/dev/sda1`

```text
/
|-- mach_kernel                       # Nawcom Atom-patched Universal Mach-O kernel (12.4 MB)
|-- legacy_kernel                     # Secondary kernel entry
|-- boot                              # Chameleon Stage 2 binary
|-- Applications/
|   `-- SpringBoard.app/
|       `-- SpringBoard               # Native Mach-O 64-bit UI executable
|-- sbin/
|   `-- launchd                       # System initializer (PID 1)
|-- bin/
|   `-- sh                            # Mach-O interactive shell
|-- usr/
|   `-- lib/
|       |-- dyld                      # Dynamic Linker (MH_DYLINKER, base 0x7fff5fc00000)
|       |-- libSystem.B.dylib         # System C runtime (MH_DYLIB)
|       `-- libSystem.dylib -> libSystem.B.dylib
|-- Extra/
|   |-- DSDT.aml                      # Custom ACPI tables for Pineview
|   |-- smbios.plist                  # MacBookAir3,1 personality
|   |-- org.chameleon.Boot.plist      # Chameleon runtime parameters
|   `-- Extensions/                   # Kernel extensions stack
`-- System/
    `-- Library/
        `-- CoreServices/
            `-- grub/
                |-- i386-pc/          # Embedded GRUB modules
                `-- grub.cfg          # Native HFS+ GRUB configuration
```

---

## 2. Bootloader Strategy: Dual GRUB / Chameleon Stack

Booting Apple XNU directly on an Intel Atom processor with non-standard ACPI tables requires precise kernel initialization:

### 2.1 Primary Loader: Embedded GRUB with Native HFS+ Driver

GRUB is installed in the MBR of `/dev/sda` with `part_msdos`, `hfsplus`, and `xnu` modules compiled into the MBR core image. The root directory is resolved dynamically on `(hd0,msdos1)`:

```grub
# /System/Library/CoreServices/grub/grub.cfg
set default="0"
set timeout=3

load_video
insmod all_video
insmod gfxterm
insmod part_msdos
insmod hfsplus
insmod xnu

menuentry 'SnowPad Darwin (Apple XNU Kernel no /dev/sda1)' --class osx --class darwin {
    insmod part_msdos
    insmod hfsplus
    insmod xnu
    set root=(hd0,msdos1)
    echo 'Carregando Apple XNU mach_kernel para Intel Atom N450...'
    xnu_kernel /mach_kernel arch=i386 cpus=1 busratio=10 -v video=VGA-1:1360x768@60
    if [ -d /Extra/Extensions ]; then
        xnu_kextdir /Extra/Extensions
    fi
}

menuentry 'Chameleon Bootloader (Mac OS X no /dev/sda1)' --class apple --class osx {
    insmod part_msdos
    insmod hfsplus
    set root=(hd0,msdos1)
    chainloader /boot
}
```

### 2.2 Secondary Loader: Chameleon v2.2

Located at `/boot`, Chameleon provides DSDT patching, SMBIOS injection, and legacy BIOS handoff:

- **SMBIOS**: MacBookAir3,1 profile (matching low-voltage single-core x86 architectures).
- **VBIOS Patching**: Forces display resolution `1360x768x32` on Intel GMA 3150.
- **DSDT**: Overrides HPET, RTC, and PIC routing to prevent Darwin boot panics.

---

## 3. Kernel Configuration and Driver Stack

Apple XNU kernel `xnu-1504` (Darwin 10.8.0 Nawcom legacy build) contains CPUID and Local APIC overrides for the Intel Atom N450:

```text
CPUID Family: 0x06 | Model: 0x1C | Stepping: 0x0A (Pineview)
Native Darwin CPU Check: Intercepted via commpage patching
Local APIC Timer: Calibrated against HPET @ 14.318 MHz
```

### 3.1 Kernel Extensions Matrix (`/Extra/Extensions/`)

| Kext Identifier | Version | Function |
|---|---|---|
| `FakeSMC.kext` | 6.26 | Intercepts SMC I/O space calls (`0x300` - `0x31F`) |
| `NullCPUPowerManagement.kext` | 1.0.0d2 | Disables AppleIntelCPUPowerManagement MSR validation |
| `EvilAppleACPIPlatform.kext` | 1.3.6 | Patched ACPI parser ignoring unsupported Atom S-states |
| `EvilIOPCIFamily.kext` | 2.6 | PCI host bridge enumeration for Pineview NM10 chipset |
| `SleepEnabler.kext` | 1.0.0 | Hooks power management sleep state triggers |
| `VoodooPS2Controller.kext` | 1.9.2 | Synaptics trackpad and PS/2 keyboard interface |
| `AppleACPIPS2Nub.kext` | 1.0.0 | Links ACPI keyboard device nub to PS/2 controller |
| `VoodooHDA.kext` | 2.9.2 | High Definition Audio driver for Realtek ALC272 |
| `HoRNDIS.kext` | 9.2 | USB Tethering network driver for Android and iOS devices |

---

## 4. Userland Contract and Mach-O Runtime

Mach-O executables compiled under modern Clang/LLVM require dynamic runtime loading via the Apple dynamic linker:

### 4.1 The Dynamic Linker (`/usr/lib/dyld`)

- **Format**: Mach-O 64-bit `MH_DYLINKER` (type `0x07`).
- **Load Address**: Base address fixed at `0x7fff5fc00000`.
- **Source**: Compiled directly from Apple Open Source `dyld-132.13`.
- **Subsystem**: Implements freestanding Mach traps (`task_self_trap`, `vm_allocate`) and BSD system calls (`mmap`, `open`, `read`, `stat64`).

### 4.2 System Library (`/usr/lib/libSystem.B.dylib`)

- **Format**: Mach-O 64-bit shared library (`MH_DYLIB`).
- **Compatibility**: Exposes the standard Darwin C runtime ABI (`fork`, `execve`, `dup2`, `signal`, `printf`, `malloc`, `time`, etc.).
- **ABI Compliance**: Provides `_NXArgc`, `_NXArgv`, `_environ`, and `_mach_init_routine` pointers expected by the Darwin `crt1.o` runtime startup.

### 4.3 Process Initialization Flow

```text
[XNU Kernel]
   |
   +--> execve("/sbin/launchd")
           |
           +--> Inspects Mach-O Header (LC_LOAD_DYLINKER)
           |       Loads /usr/lib/dyld at 0x7fff5fc00000
           |       Jumps to __dyld_start
           |
           +--> [dyld]
                   Loads /usr/lib/libSystem.B.dylib
                   Binds symbol imports and relocations
                   Jumps to launchd:main()
                   |
                   +--> [launchd (PID 1)]
                           Opens /dev/console
                           Spawns /Applications/SpringBoard.app/SpringBoard
```
