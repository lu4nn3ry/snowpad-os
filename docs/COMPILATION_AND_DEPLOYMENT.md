# Compilation and Deployment Guide: Pure Darwin Standalone

This guide details the procedure for building the native runtime libraries, dynamic linker, network stack, and standalone SSH server for Apple Darwin running on the Intel Atom N450 (Pineview) platform.

---

## 1. Toolchain Overview

The cross-compilation pipeline runs under Ubuntu WSL2:
- **Compiler**: Clang 17 (`/opt/swift/usr/bin/clang`)
- **Linker**: LLVM Mach-O Linker (`/opt/ios-sdk/darwin.xtoolsdk/toolset/bin/ld64.lld`)
- **SDK**: macOS SDK headers (`/opt/ios-sdk/darwin.xtoolsdk/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk`)
- **Code Signing**: `ldid` (`/opt/ldid-src/ldid -S`)

---

## 2. Dropbear SSH Server Compilation for Darwin x86_64

Dropbear was selected for independent remote access due to its clean BSD socket implementation and bundled cryptography (LibTomCrypt and LibTomMath), removing dependencies on OpenSSL.

### Configuration
```bash
cd /home/luann/snowpad_build/dropbear

export CC="/opt/swift/usr/bin/clang -target x86_64-apple-darwin \
  -isysroot /opt/ios-sdk/darwin.xtoolsdk/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk \
  -fuse-ld=/opt/ios-sdk/darwin.xtoolsdk/toolset/bin/ld64.lld \
  -Wl,-platform_version,macos,10.13,10.13"

cat << 'EOF' > localoptions.h
#define DROPBEAR_SVR_DROP_PRIVS 0
#define DROPBEAR_SVR_MULTIUSER 0
#define DROPBEAR_X11FWD 0
#define DROPBEAR_UTMP 0
#define DROPBEAR_WTMP 0
EOF
cp localoptions.h src/localoptions.h

./configure --host=x86_64-apple-darwin \
  --disable-zlib \
  --disable-pam \
  --disable-lastlog \
  --disable-utmp \
  --disable-utmpx \
  --disable-wtmp \
  --disable-wtmpx \
  --disable-loginfunc
```

### Build and Sign
```bash
make dropbear dropbearkey
/opt/ldid-src/ldid -S dropbear
/opt/ldid-src/ldid -S dropbearkey
```

Resulting binaries:
- `dropbear`: Mach-O 64-bit x86_64 executable (282 KB)
- `dropbearkey`: Mach-O 64-bit x86_64 executable (139 KB)
- Linked strictly against `/usr/lib/libSystem.B.dylib`.

---

## 3. Dedicated Network Stack Initializer (`netsetup`)

Because standard modern `ifconfig` contains modern packet-scheduler dependencies (`net/pktsched`), a focused BSD socket initializer was implemented in C (`netsetup.c`).

### Compilation
```bash
/opt/swift/usr/bin/clang -target x86_64-apple-darwin \
  -isysroot /opt/ios-sdk/darwin.xtoolsdk/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk \
  -fuse-ld=/opt/ios-sdk/darwin.xtoolsdk/toolset/bin/ld64.lld \
  -Wl,-platform_version,macos,10.13,10.13 \
  netsetup.c -o /tmp/netsetup

/opt/ldid-src/ldid -S /tmp/netsetup
```

### Execution at Boot
When `/sbin/launchd` executes as PID 1:
1. Loops through `lo0`, `en0`, and `en1`.
2. Activates interface flags (`IFF_UP | IFF_RUNNING`).
3. Sets static IP addresses (`192.168.0.70` for `en0` Ethernet, `192.168.0.71` for `en1` USB Tethering).
4. Generates `/etc/resolv.conf`.
5. Starts `/usr/sbin/dropbear -R -B -p 22 -E &`.

---

## 4. Hardware Driver Injection Matrix

The `/Extra/Extensions/` directory on `/dev/sda1` contains all hardware kexts:

| KEXT Name | Purpose | Target Hardware |
|---|---|---|
| `AtherosL1cEthernet.kext` | Fast Ethernet Driver | Qualcomm Atheros AR8132 (`1969:1062`) |
| `HoRNDIS.kext` | USB Tethering Driver | Android / iPhone USB Tethering |
| `FakeSMC.kext` | Apple SMC Emulation | Universal x86 PC |
| `NullCPUPowerManagement.kext` | Disable Intel MSR panic | Intel Atom N450 Pineview |
| `EvilAppleACPIPlatform.kext` | ACPI Bus Enumeration | Intel NM10 Express Chipset |
| `EvilIOPCIFamily.kext` | PCI Subsystem Driver | Intel NM10 Express Chipset |
| `VoodooHDA.kext` | High Definition Audio | Realtek ALC272 HDA |
| `VoodooPS2Controller.kext` | Keyboard & Trackpad | Synaptics PS/2 Port |
| `SleepEnabler.kext` | Sleep/Wake support | Intel Atom Pineview |

---

## 5. Standalone Bootloader Configuration

The GRUB bootloader is embedded into MBR sector 0 of `/dev/sda` and reads its configuration from `(hd0,msdos1)/System/Library/CoreServices/grub/grub.cfg`.

Menu entries provided:
1. `SnowPad Darwin 64-bit (Apple XNU no /dev/sda1)`: Boots `mach_kernel` in native 64-bit mode.
2. `SnowPad Darwin 32-bit (Apple XNU i386 no /dev/sda1)`: Boots `mach_kernel` with `arch=i386`.
3. `Chameleon Bootloader (Mac OS X no /dev/sda1)`: Chainloads `/boot` on `/dev/sda1`.
