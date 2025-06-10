# Building

## Requirements
- A working rustup installation (even in Nix, since CargoKit uses rustup commands)
- [Flutter Rust Bridge](https://github.com/fzyzcjy/flutter_rust_bridge) - [Codegen](https://crates.io/crates/flutter_rust_bridge_codegen)
- bindgen-cli (cargo install --force --locked bindgen-cli)
- Flutter SDK (Running flutter doctor -v will warn if anything is missing)
- Perl
- Android NDK and SDK (at least SDK API Level 21?)

### Linux

libssl-dev
cmake
ninja-build
clang
libstdc++-12-dev
pkg-config
libgtk-3-dev
mesa-utils
[libayatana-appindicator3-dev](https://github.com/leanflutter/tray_manager#linux-requirements)

#### Steps (apt as example)
sudo apt install libssl-dev cmake ninja-build clang libstdc++-12-dev pkg-config libgtk-3-dev mesa-utils libayatana-appindicator3-dev
rustup toolchain nightly-x86_64-unknown-linux-gnu

### Nixos

There is a flake with a working environment.

The use of [Nix-direnv](https://github.com/nix-community/nix-direnv) is recommended.


### MacOS

brew install cmake llvm

### Windows

Developer mode is necessary to use symlinks for building plugins, in the terminal, run this command:
start ms-settings:developers
Or access directly via Settings -> Developers

Then toggle Developer Mode


#### Choco
Admin prompt:
```powershell
choco install strawberryperl
```

Normal prompt (or it will complain)
```powershell
choco install flutter
```

#### Android

It's recommended to build it from Linux, I haven't tried Windows, but MacOS gave many problems.

##### libc++_shared.so not found
https://github.com/fzyzcjy/flutter_rust_bridge/issues/883

Inside $NDK_HOME/sources/cxx-stl/llvm-libc++/libs/ there should be precompiled ones, but since Google changes things very often (at least in NDK 22 there were), it's quite possible your installation doesn't contain them, in that case you can find them here:
https://chromium.googlesource.com/android_tools/+/20ee6d20/ndk/sources/cxx-stl/llvm-libc++/libs

Only these targets:
- arm64-v8a
- armeabi-v7a
- x86
- x86_64

Copy them here: ./android/app/src/main/jniLibs

### Optional

There is a [Justfile](https://github.com/casey/just) with a few commands already defined

## Steps

The folder lib/src/rust needs to exist for the frb generation of bindings, otherwise it will fail.

- flutter pub get
- flutter_rust_bridge_codegen generate
- flutter run

It shouldn't be necessary, but if the dart codegen doesn't work on run, execute manually to generate providers and language files (this is in case something has changed)


## Times

Ryzen 9 5900X / 48GB 3200Mhz

Windows:
- Complete build:
435s



## Troubleshooting
If the NDK gives any problem, try first to update CMake
