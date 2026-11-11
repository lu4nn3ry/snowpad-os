# SnowPad OS: Compilation and Deployment Guide

## Abstract

This guide provides instructions for cross-compiling native Apple Darwin Mach-O 64-bit binaries in a Linux / WSL environment, building `dyld` and `libSystem` directly from open source code, and deploying the system to the Intel Atom netbook.

---

## 1. Prerequisites and Toolchain Setup

The cross-compilation environment runs on Ubuntu 24.04 (WSL 2) using Clang 17 and Apple Darwin SDKs:

* **Compiler**: Clang 17 (`/opt/swift/usr/bin/clang`, `/opt/swift/usr/bin/clang++`)
* **Mach-O Linker**: LLVM `ld64.lld` (`/opt/ios-sdk/darwin.xtoolsdk/toolset/bin/ld64.lld`)
* **Codesigning**: `ldid` (`/opt/ldid-src/ldid`)
* **Darwin SDK**: macOS 10.15/11.0 SDK headers (`/opt/ios-sdk/darwin.xtoolsdk/.../MacOSX.sdk`)

---

## 2. Compiling the Dynamic Linker (`/usr/lib/dyld`)

`dyld` is the foundation of the Mach-O userland, loaded by XNU whenever an executable contains `LC_LOAD_DYLINKER`:

```bash
# 1. Clone Apple Open Source dyld (Snow Leopard 10.6.8 tag)
git clone --depth 1 -b dyld-132.13 https://github.com/apple-oss-distributions/dyld.git /tmp/dyld

# 2. Compile object files
CLANGXX="/opt/swift/usr/bin/clang++"
CLANG="/opt/swift/usr/bin/clang"
SDK="/opt/ios-sdk/darwin.xtoolsdk/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk"
COMMON_FLAGS="-target x86_64-apple-darwin -isysroot $SDK -I/tmp/dyld/include -I/tmp/dyld/src -I/tmp/dyld/launch-cache -Wno-register -Wno-deprecated-declarations -Wno-vla-cxx-extension -O2"

mkdir -p /tmp/dyld/build_objs
$CLANG -target x86_64-apple-darwin -isysroot "$SDK" -c /tmp/dyld/src/dyldStartup.s -o /tmp/dyld/build_objs/dyldStartup.o
$CLANGXX $COMMON_FLAGS -c /tmp/dyld/src/dyldInitialization.cpp -o /tmp/dyld/build_objs/dyldInitialization.o
$CLANGXX $COMMON_FLAGS -c /tmp/dyld/src/dyld.cpp -o /tmp/dyld/build_objs/dyld.o
$CLANGXX $COMMON_FLAGS -c /tmp/dyld/src/dyldAPIs.cpp -o /tmp/dyld/build_objs/dyldAPIs.o
$CLANG $COMMON_FLAGS -c /tmp/dyld/src/dyldExceptions.c -o /tmp/dyld/build_objs/dyldExceptions.o
$CLANGXX $COMMON_FLAGS -c /tmp/dyld/src/dyld_gdb.cpp -o /tmp/dyld/build_objs/dyld_gdb.o
$CLANG $COMMON_FLAGS -c /tmp/dyld/src/glue.c -o /tmp/dyld/build_objs/glue.o
$CLANGXX $COMMON_FLAGS -c /tmp/dyld/src/ImageLoader.cpp -o /tmp/dyld/build_objs/ImageLoader.o
$CLANGXX $COMMON_FLAGS -c /tmp/dyld/src/ImageLoaderMachO.cpp -o /tmp/dyld/build_objs/ImageLoaderMachO.o
$CLANGXX $COMMON_FLAGS -c /tmp/dyld/src/ImageLoaderMachOClassic.cpp -o /tmp/dyld/build_objs/ImageLoaderMachOClassic.o
$CLANGXX $COMMON_FLAGS -c /tmp/dyld/src/ImageLoaderMachOCompressed.cpp -o /tmp/dyld/build_objs/ImageLoaderMachOCompressed.o
$CLANG -target x86_64-apple-darwin -isysroot "$SDK" -c /tmp/dyld/src/stub_binding_helper.s -o /tmp/dyld/build_objs/stub_binding_helper.o
$CLANGXX $COMMON_FLAGS -c /tmp/dyld/src/dyldNew.cpp -o /tmp/dyld/build_objs/dyldNew.o
$CLANG -target x86_64-apple-darwin -isysroot "$SDK" -c /tmp/dyld/src/dyld_stub_binder.s -o /tmp/dyld/build_objs/dyld_stub_binder.o

# 3. Compile support stubs (direct Darwin syscalls)
$CLANG -target x86_64-apple-darwin -isysroot "$SDK" -c /tmp/dyld_support.c -o /tmp/dyld/build_objs/dyld_support.o
$CLANGXX -target x86_64-apple-darwin -isysroot "$SDK" -I/tmp/dyld/include -I/tmp/dyld/src -Wno-c++11-narrowing -c /tmp/dyld/dyld_stubs.cpp -o /tmp/dyld/build_objs/dyld_stubs.o

# 4. Link dyld
LD64="/opt/ios-sdk/darwin.xtoolsdk/toolset/bin/ld64.lld"
$LD64 -arch x86_64 -platform_version macos 10.15 11.0 -syslibroot "$SDK" \
    -e __dyld_start /tmp/dyld/build_objs/*.o -o /tmp/dyld/dyld_linked

# 5. Patch Mach-O filetype to 0x07 (MH_DYLINKER) and sign
python3 -c '
with open("/tmp/dyld/dyld_linked", "r+b") as f:
    f.seek(12)
    f.write(bytes([7, 0, 0, 0]))
'
/opt/ldid-src/ldid -S /tmp/dyld/dyld_linked
```

---

## 3. Compiling the System Runtime (`/usr/lib/libSystem.B.dylib`)

`libSystem.B.dylib` provides the POSIX lifecycle and C standard library implementation over native XNU system calls:

```bash
$CLANG -target x86_64-apple-darwin -dynamiclib \
    -install_name /usr/lib/libSystem.B.dylib \
    -Wl,-platform_version,macos,10.15,11.0 \
    --sysroot=$SDK -fuse-ld=$LD \
    /tmp/libSystem_pure.c -o /tmp/libSystem.B.dylib

/opt/ldid-src/ldid -S /tmp/libSystem.B.dylib
```

---

## 4. Compiling the Userland Binaries

```bash
# 1. Compile launchd (PID 1)
$CLANG -target x86_64-apple-darwin -Wl,-platform_version,macos,10.15,11.0 \
    --sysroot=$SDK -fuse-ld=$LD launchd.c -o launchd
$LDID -S launchd

# 2. Compile SpringBoard UI
$CLANG -target x86_64-apple-darwin -Wl,-platform_version,macos,10.15,11.0 \
    --sysroot=$SDK -fuse-ld=$LD springboard_macho.c -o SpringBoard
$LDID -S SpringBoard
```

---

## 5. Deployment Over SSH

When booted into the Alpine Linux maintenance medium:

```bash
# 1. Copy runtime libraries
scp dyld root@192.168.0.27:/mnt/snowpad/usr/lib/dyld
scp libSystem.B.dylib root@192.168.0.27:/mnt/snowpad/usr/lib/libSystem.B.dylib

# 2. Deploy userland
scp launchd root@192.168.0.27:/mnt/snowpad/sbin/launchd
scp SpringBoard root@192.168.0.27:/mnt/snowpad/Applications/SpringBoard.app/SpringBoard

# 3. Set root ownership and execution permissions
ssh root@192.168.0.27 '
chown -R 0:0 /mnt/snowpad/usr /mnt/snowpad/sbin /mnt/snowpad/Applications
chmod 755 /mnt/snowpad/usr/lib/dyld /mnt/snowpad/usr/lib/libSystem.B.dylib
chmod 755 /mnt/snowpad/sbin/launchd /mnt/snowpad/Applications/SpringBoard.app/SpringBoard
sync
'
```
