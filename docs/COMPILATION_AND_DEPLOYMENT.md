# SnowPad Darwin Compilation and Deployment Guide

Step-by-step developer manual for building Mach-O binaries in WSL using xtool / Clang and deploying them to the SnowPad Darwin partition on the Itautec Infoway W7020 netbook.

---

## 1. Prerequisites

The cross-compilation environment runs on Ubuntu under Windows Subsystem for Linux (WSL).

### Required Toolchain Components

* **Compiler**: Apple / LLVM Clang 17 (`/opt/swift/usr/bin/clang`)
* **Mach-O Linker**: `ld64.lld` (`/opt/ios-sdk/darwin.xtoolsdk/toolset/bin/ld64.lld`)
* **Darwin SDK**: macOS SDK (`/opt/ios-sdk/darwin.xtoolsdk/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk`)
* **Code Signer**: `ldid` with pseudo-signing capabilities (`/opt/ldid-src/ldid`)
* **Cross-tool Manager**: `xtool` (`/usr/local/bin/xtool`)

---

## 2. Compiling Native Darwin Mach-O Binaries

### Environment Variables Setup

```bash
export CLANG=/opt/swift/usr/bin/clang
export SDK=/opt/ios-sdk/darwin.xtoolsdk/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk
export LD=/opt/ios-sdk/darwin.xtoolsdk/toolset/bin/ld64.lld
export LDID=/opt/ldid-src/ldid
```

### Compiling PID 1 Init (`launchd`)

The initialization daemon must be compiled as a standalone Mach-O executable:

```bash
$CLANG -target x86_64-apple-darwin \
  -Wl,-platform_version,macos,10.15,11.0 \
  --sysroot=$SDK \
  -fuse-ld=$LD \
  src/darwin/launchd.c -o launchd

$LDID -S launchd
```

Verify binary format:
```bash
file launchd
# Expected output: launchd: Mach-O 64-bit x86_64 executable, flags:<NOUNDEFS|DYLDLINK|TWOLEVEL|PIE>
```

### Compiling SpringBoard Application

To compile the SpringBoard application bundle executable:

```bash
$CLANG -target x86_64-apple-darwin \
  -Wl,-platform_version,macos,10.15,11.0 \
  --sysroot=$SDK \
  -fuse-ld=$LD \
  src/darwin/springboard_macho.c -o SpringBoard

$LDID -S SpringBoard
```

---

## 3. Remote Deployment via SSH/SFTP

The target machine is accessible over the local wireless network `LNET` via passwordless SSH key authentication.

### Target Machine Details
* **Host**: `192.168.0.27` (or alias `atom`)
* **User**: `root`
* **SSH Key**: `~/.ssh/id_ed25519`
* **HFS+ Mount Point**: `/mnt/snowpad` (Partition `/dev/sda1`)

### Deployment Procedure

1. Package compiled binaries:
```bash
tar -czf /tmp/darwin_binaries.tar.gz launchd SpringBoard
```

2. Copy archive to the target netbook:
```bash
scp -i ~/.ssh/id_ed25519 /tmp/darwin_binaries.tar.gz root@192.168.0.27:/tmp/
```

3. Extract onto the Apple HFS+ partition:
```bash
ssh -i ~/.ssh/id_ed25519 root@192.168.0.27 << 'EOF'
mkdir -p /mnt/snowpad/sbin /mnt/snowpad/Applications/SpringBoard.app
tar -xzf /tmp/darwin_binaries.tar.gz -C /tmp/
cp /tmp/launchd /mnt/snowpad/sbin/launchd
cp /tmp/SpringBoard /mnt/snowpad/Applications/SpringBoard.app/SpringBoard
chmod 755 /mnt/snowpad/sbin/launchd /mnt/snowpad/Applications/SpringBoard.app/SpringBoard
rm -f /tmp/darwin_binaries.tar.gz /tmp/launchd /tmp/SpringBoard
EOF
```

---

## 4. Boot Diagnostics and Kernel Flags

When booting Darwin from Chameleon or GRUB, use the following boot arguments for diagnostic logging on the external LG TV monitor:

| Flag | Purpose |
|---|---|
| `-v` | Verbose mode: prints all kernel, ACPI, and driver messages to screen |
| `-f` | Force ignore boot cache: rebuilds driver table from `/Extra/Extensions/` |
| `-s` | Single-user mode: boots directly into root command prompt |
| `cpus=1` | Limits execution to 1 physical core (prevents hyperthreading races on Atom) |
| `busratio=10` | Enforces exact bus ratio for the 1.66 GHz Atom N450 clock |
| `video=VGA-1:1360x768@60` | Configures external VGA port for native LG TV resolution |

### Recovering from Kernel Panic

If a panic occurs during boot:
1. Reboot the machine and select `SnowPad OS (TV Hub, RetroArch & Apps)` from the GRUB menu.
2. Log into the recovery environment via SSH (`ssh root@192.168.0.27`).
3. Check the crash log and adjust the faulty `.kext` in `/mnt/snowpad/Extra/Extensions/`.
4. Re-run `fsck.hfsplus -f /dev/sda1` if the filesystem was not cleanly unmounted.
