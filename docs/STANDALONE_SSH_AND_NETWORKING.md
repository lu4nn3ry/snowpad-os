# Standalone Darwin SSH and Networking Architecture

This document describes the design, implementation, and deployment of the standalone, autonomous SSH server and networking stack running natively under pure Apple Darwin on the Intel Atom N450 (Pineview) platform.

---

## 1. Network Hardware Assessment

The target machine is the Itautec Infoway W7020 netbook. A complete hardware audit reveals the following network controllers:

1. **Ethernet Controller (Qualcomm Atheros AR8132)**:
   - PCI ID: `1969:1062`
   - Class: Fast Ethernet (10/100 Mbps)
   - Driver: `AtherosL1cEthernet.kext` (injected into `/Extra/Extensions/`)
   - Interface Name: `en0`

2. **Wireless LAN Controller (Realtek RTL8192SE / RTL8191SE)**:
   - PCI ID: `10ec:8172`
   - Class: IEEE 802.11b/g/n PCIe
   - Hardware Reality: Realtek and Apple never produced a stable 64-bit or 32-bit native PCIe driver for Mac OS X / Darwin for this specific PCIe chip. There is no working community PCIe kext for `10ec:8172`.
   - Architectural Alternative: Network connectivity is routed through the native Atheros AR8132 Ethernet controller or via zero-configuration smartphone USB tethering (`HoRNDIS.kext`).

3. **Smartphone USB Tethering (HoRNDIS Gateway)**:
   - Driver: `HoRNDIS.kext` (injected into `/Extra/Extensions/`)
   - Interface Name: `en1`
   - Functionality: Provides immediate, driverless Wi-Fi/4G/5G internet sharing when any modern smartphone (Android or iOS) is connected to any USB port with USB Tethering enabled.

---

## 2. Dropbear SSH Server Cross-Compilation

To maintain complete independence from macOS userland frameworks while guaranteeing minimal memory footprint and zero external library dependencies, Dropbear SSH was selected and compiled directly for `x86_64-apple-darwin`.

### Build Environment
- **Compiler**: Clang 17 (`/opt/swift/usr/bin/clang`)
- **Linker**: LLVM Mach-O Linker (`ld64.lld`)
- **SDK**: `MacOSX.sdk` (macOS 10.13 target ABI compatibility)
- **Code Signer**: `ldid -S`

### Configuration Adjustments
Dropbear uses bundled `libtomcrypt` and `libtommath` for all cryptographic operations (RSA, DSS, ECDSA, ED25519, AES, ChaCha20-Poly1305). To adapt Dropbear for Darwin's security model without requiring Linux-specific `setresgid()`, the following compilation flags were defined in `localoptions.h`:

```c
#define DROPBEAR_SVR_DROP_PRIVS 0
#define DROPBEAR_SVR_MULTIUSER 0
#define DROPBEAR_X11FWD 0
#define DROPBEAR_UTMP 0
#define DROPBEAR_WTMP 0
```

### Compiler Command Line
```bash
export CC="/opt/swift/usr/bin/clang -target x86_64-apple-darwin \
  -isysroot /opt/ios-sdk/darwin.xtoolsdk/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk \
  -fuse-ld=/opt/ios-sdk/darwin.xtoolsdk/toolset/bin/ld64.lld \
  -Wl,-platform_version,macos,10.13,10.13"

./configure --host=x86_64-apple-darwin \
  --disable-zlib \
  --disable-pam \
  --disable-lastlog \
  --disable-utmp \
  --disable-utmpx \
  --disable-wtmp \
  --disable-wtmpx \
  --disable-loginfunc

make dropbear dropbearkey
/opt/ldid-src/ldid -S dropbear
/opt/ldid-src/ldid -S dropbearkey
```

### Deployed Binaries
- `/usr/sbin/dropbear` (282 KB, Mach-O 64-bit x86_64, linked strictly to `/usr/lib/libSystem.B.dylib`)
- `/usr/sbin/sshd -> dropbear` (symlink for standard compatibility)
- `/usr/bin/dropbearkey` (139 KB, Mach-O 64-bit key generator)

---

## 3. Network Initializer (`netsetup`)

Because standard userland `ifconfig` in modern source trees carries complex packet scheduling dependencies (`net/pktsched`), a focused BSD socket initializer was developed in C (`scratch/netsetup.c`) and deployed as `/sbin/netsetup`.

### Functionality
1. **Loopback Configuration**:
   - Binds `lo0` to `127.0.0.1` with netmask `255.0.0.0`.
   - Sets flags: `IFF_UP | IFF_RUNNING | IFF_LOOPBACK`.
2. **Physical Interface Initialization**:
   - Probes `en0` (Atheros AR8132 Fast Ethernet) and `en1` (HoRNDIS USB Tethering).
   - Activates interface flags (`IFF_UP | IFF_RUNNING`).
   - Assigns static fallback address:
     - `en0`: `192.168.0.70/24`
     - `en1`: `192.168.0.71/24`
3. **DNS Configuration**:
   - Generates `/etc/resolv.conf`:
     ```text
     nameserver 192.168.0.1
     nameserver 1.1.1.1
     nameserver 8.8.8.8
     ```

---

## 4. Boot Orchestration (`/sbin/launchd`)

The Apple XNU kernel executes `/sbin/launchd` as process identifier 1 (PID 1). In SnowPad OS, this init script coordinates hardware and network startup:

```sh
#!/bin/sh
# 1. Console I/O Redirection
exec 0</dev/console
exec 1>/dev/console
exec 2>/dev/console

umask 022
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin
export TERM=xterm-color
export HOME=/var/root

# 2. Filesystems
/sbin/mount -uw / 2>/dev/null
/sbin/mount -t devfs devfs /dev 2>/dev/null
/sbin/mount -t fdesc -o union stdin /dev 2>/dev/null

# 3. Network Stack
/sbin/netsetup

# 4. Independent SSH Daemon
mkdir -p /etc/dropbear /var/root/.ssh /var/run /var/log
/usr/sbin/dropbear -R -B -p 22 -E &

# 5. Graphical Interface
if [ -x /Applications/SpringBoard.app/SpringBoard ]; then
    /Applications/SpringBoard.app/SpringBoard &
fi

# 6. Fallback Shell
while true; do
    if [ -x /bin/bash ]; then
        /bin/bash -i < /dev/console > /dev/console 2>&1
    elif [ -x /bin/sh ]; then
        /bin/sh -i < /dev/console > /dev/console 2>&1
    else
        sleep 5
    fi
done
```

---

## 5. Security & Key Management

- **Public Key Injected**: Authorized ED25519 public key (`chronocat-iphone`) is placed in `/var/root/.ssh/authorized_keys`.
- **Permissions**:
  - `/var/root`: `0700` (`drwx------`)
  - `/var/root/.ssh`: `0700` (`drwx------`)
  - `/var/root/.ssh/authorized_keys`: `0600` (`-rw-------`)
- **Remote Login**:
  ```bash
  ssh root@192.168.0.70
  ```
