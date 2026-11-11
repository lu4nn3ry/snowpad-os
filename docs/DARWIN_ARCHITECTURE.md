# SnowPad Darwin Architecture & Specification

Technical specification and implementation reference for running pure Apple Darwin (XNU 1504 / macOS Snow Leopard 10.6.8 base) with the iOS 3.2 SpringBoard userland on Intel Atom N450 hardware.

---

## 1. Hardware Platform

* **Target Device**: Itautec Infoway W7020 Netbook
* **Processor**: Intel Atom N450 (Pineview-M, 45nm)
  * Cores / Threads: 1 Core / 2 Threads (HyperThreading enabled)
  * Clock Speed: 1.66 GHz (Bus Ratio: 10, FSB: 667 MHz)
  * Instruction Sets: x86 (IA-32), Intel 64 (EM64T), MMX, SSE, SSE2, SSE3, SSSE3
* **System Memory**: 2048 MB DDR2 667 MHz SODIMM
* **Chipset**: Intel NM10 Express Chipset (ICH8M LPC interface)
* **Graphics**: Intel GMA 3150 (Pineview Integrated Graphics Controller)
  * Vendor ID: `0x8086`, Device ID: `0xa011` / `0xa012`
  * Framebuffer Output: 1024x600 (LVDS internal panel) / 1360x768 @ 60 Hz (external VGA to LG TV)
* **Audio**: Realtek ALC663 High Definition Audio Codec (HDA)
* **Storage**: 320 GB 2.5-inch SATA Internal Hard Disk (`/dev/sda`)
* **Network**:
  * Ethernet: Realtek RTL8102E / RTL8103E 10/100 Mbps PCI-E
  * Wireless: Realtek RTL8192SE / RTL8191SE 802.11b/g/n PCIe Half-Mini Card (`0x10ec:0x8172`)
* **Input**:
  * Built-in PS/2 Keyboard and Synaptics PS/2 Touchpad
  * External Microntek USB Joystick / Gamepad (6 Axes, 12 Buttons)

---

## 2. Disk Layout and Filesystem Structure

The internal 320 GB hard drive is partitioned with a standard Master Boot Record (MBR) table:

```text
Disk /dev/sda: 320 GB (625,142,448 sectors)

Device     Boot  Start Sector  End Sector  Size   Type   Filesystem
/dev/sda1  *            2048   587202559   279 GB  0xAF   Apple HFS+ (Journaled)
/dev/sda2          587202560   625142447    18 GB  0x83   Linux ext4 (Recovery/Hub)
```

### Darwin Root Partition Hierarchy (`/dev/sda1`)

```text
/
├── mach_kernel                # Nawcom Legacy Atom Kernel (Universal i386/x86_64, 12.4 MB)
├── legacy_kernel              # Secondary kernel fallback
├── boot                       # Chameleon bootloader binary (Enoch revision)
├── Extra/
│   ├── DSDT.aml               # Native DSDT with HPET, RTC, and LPC patches
│   ├── smbios.plist           # System model definition (MacBookAir3,1)
│   ├── org.chameleon.Boot.plist # Kernel flags, graphics resolution, arch settings
│   └── Extensions/            # Injected Darwin kernel extensions
│       ├── FakeSMC.kext       # Apple System Management Controller emulation
│       ├── NullCPUPowerManagement.kext # Disables AppleIntelCPUPowerManagement MSR panic
│       ├── EvilAppleACPIPlatform.kext  # Sanitizes PC BIOS ACPI table parsing
│       ├── EvilIOPCIFamily.kext        # Fixes PCI bus space allocation
│       ├── SleepEnabler.kext           # Resolves power management sleep trap
│       ├── AppleACPIPS2Nub.kext        # PS/2 controller stub
│       ├── VoodooPS2Controller.kext    # Keyboard and touchpad driver
│       ├── VoodooHDA.kext              # Realtek ALC663 sound engine
│       ├── RealtekRTL8100.kext         # 10/100 Ethernet driver
│       ├── HoRNDIS.kext                # USB smartphone tethering driver
│       └── RTL8192se.kext              # Realtek wireless network extension
├── sbin/
│   └── launchd                # Mach-O PID 1 init supervisory process
├── bin/
│   └── sh                     # Mach-O interactive shell
└── Applications/
    └── SpringBoard.app/
        └── SpringBoard        # Mach-O SpringBoard launcher binary
```

---

## 3. Kernel Architecture & Patches

### The Intel Atom Pineview Constraint

The stock Apple XNU kernel (`xnu-1504.15.3` from Mac OS X 10.6.8) panics during early initialization on Intel Atom processors for three reasons:

1. **CPUID Validation**: Apple's CPU topology detection in `osfmk/i386/cpuid.c` does not recognize the Pineview family/model (`Family 6, Model 28, Stepping 10`) and treats it as an unsupported architecture, aborting execution.
2. **Local APIC Panic (`lapic_init`)**: The in-order execution pipeline of the Atom N450 handles timer interrupts and LAPIC register mapping differently from Core 2 Duo and Nehalem architectures, leading to a fatal `panic("lapic_init: Unknown CPU")`.
3. **Power Management MSRs**: `AppleIntelCPUPowerManagement.kext` writes directly to Mac-specific Model-Specific Registers (`MSR_IA32_PERF_STATUS`) to manage SpeedStep. PC motherboards lack these exact registers, triggering immediate kernel panic.

### The Nawcom Legacy Kernel Solution

To run Darwin natively on the Atom N450, we deployed the **Nawcom Legacy Kernel v2 (Darwin 10.8.0 / XNU 1504)**:

* **Format**: Universal Mach-O Fat Binary (`0xCAFEBABE`) containing both `i386` and `x86_64` code slices.
* **Patches Applied**:
  * Emulates Core 2 Duo CPUID flags for the scheduler and Mach thread subsystem.
  * Adjusts `tsc_init` calculation for the 667 MHz FSB.
  * Disables panic traps on unsupported MSR writes.
  * Allows execution with `arch=i386` (32-bit kernel mode) or `arch=x86_64` (64-bit kernel mode).

---

## 4. Bootloader Configuration

### Chameleon Boot Parameters (`/Extra/org.chameleon.Boot.plist`)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Kernel</key>
    <string>mach_kernel</string>
    <key>Kernel Flags</key>
    <string>arch=i386 cpus=1 busratio=10 -v video=VGA-1:1360x768@60</string>
    <key>GraphicsMode</key>
    <string>1360x768x32@60</string>
    <key>GraphicsEnabler</key>
    <string>Yes</string>
    <key>UseKernelCache</key>
    <string>No</string>
    <key>Timeout</key>
    <string>3</string>
</dict>
</plist>
```

### GRUB Direct XNU Configuration (`/boot/grub/grub.cfg`)

GRUB contains native `xnu.mod` and `hfsplus.mod` modules capable of reading HFS+ and loading XNU kernels directly:

```grub
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
```

---

## 5. Mach-O Userland Toolchain & Compilation

All binaries running under Darwin are built using LLVM Clang 17 targeting Darwin, linked with `ld64.lld`, and signed with `ldid`:

### Compilation Flags

```bash
CLANG=/opt/swift/usr/bin/clang
SDK=/opt/ios-sdk/darwin.xtoolsdk/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk
LD=/opt/ios-sdk/darwin.xtoolsdk/toolset/bin/ld64.lld
LDID=/opt/ldid-src/ldid

# Compile Mach-O 64-bit binary
$CLANG -target x86_64-apple-darwin \
  -Wl,-platform_version,macos,10.15,11.0 \
  --sysroot=$SDK \
  -fuse-ld=$LD \
  source.c -o output_binary

# Apply Apple entitlements and ad-hoc code signature
$LDID -S output_binary
```

### PID 1 Supervisory Contract (`/sbin/launchd`)

When XNU finishes initializing device drivers, it transfers execution to `/sbin/launchd`. The process contract requires:

1. Binding standard descriptors `0`, `1`, `2` to `/dev/console`.
2. Intercepting `SIGCHLD` to reap terminated child processes (`waitpid`).
3. Spawning the primary userland interface (`/Applications/SpringBoard.app/SpringBoard`).
4. Maintaining a persistent supervisory loop to ensure system stability.
