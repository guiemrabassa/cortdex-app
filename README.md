# Cortdex


# Building

## Requirements
- A working rustup installation (even in Nix, since CargoKit uses rustup commands) with a nightly toolchain as default (?)
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

There is a flake with a working environment

The use of [Nix-direnv](https://github.com/nix-community/nix-direnv) is recommended.


### MacOS

brew install cmake llvm

### Windows

Developer mode is necessary to use symlinks for building plugins, in the terminal, run this command:
start ms-settings:developers
Or access directly via Settings -> Developers

Then toggle Developer Mode


#### Choco
```powershell
choco install strawberryperl
```


### Optional

- [Just](https://github.com/casey/just) (Command runner utility)



## Steps

The folder lib/src/rust needs to exist for the frb generation of bindings, otherwise it will fail.

The [justfile](./justfile) contains all commands necessary for the build.

- flutter pub get
- flutter_rust_bridge_codegen generate


## Times

Ryzen 9 5900X / 48GB 3200Mhz

Windows:
- Complete build:
435s



## Troubleshooting
If the NDK gives any problem, try first to update CMake
