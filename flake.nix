{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    naersk.url = "github:nix-community/naersk";
    rust-overlay.url = "github:oxalica/rust-overlay";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, flake-utils, naersk, nixpkgs, rust-overlay }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = (import nixpkgs) {
          inherit system overlays;
          config = {
            android_sdk.accept_license = true;
            allowUnfree = true;
          };
        };
        buildToolsVersions = "34.0.0";
        androidComposition = pkgs.androidenv.composeAndroidPackages {
          buildToolsVersions = [ buildToolsVersions ];
          platformVersions = [ "23" "29" "30" "31" "32" "33" "34" "35" "28" ];
          abiVersions = [ "armeabi-v7a" "arm64-v8a" ];
          includeNDK = true;
          ndkVersions = ["26.3.11579264"];
          cmakeVersions = [ "3.22.1" ];
        };
        androidSdk = androidComposition.androidsdk;

        graphics = with pkgs; [
          vulkan-headers
          vulkan-loader
          vulkan-tools
          vulkan-validation-layers
          shaderc
          shaderc.bin
          shaderc.static
          shaderc.dev
          shaderc.lib
        ];

        ml = with pkgs; [
          cudaPackages_12_4.cudatoolkit
          cudaPackages_12_4.cudnn
          cudaPackages_12_4.cuda_cudart
        ];

        buildInputs = with pkgs; [
          xorg.libXcursor
          xorg.libXi
          xorg.libXrandr
          udev
          alsa-lib
          libxkbcommon

          zlib
          
          gdb
          jdk17
          androidSdk
          flutter
          libayatana-appindicator # For flutter notifications plugin
          gtk3
          wayland
          
          openssl
          openssl.dev
        ];

        # naersk' = pkgs.callPackage naersk { };
        nativeBuildInputs = with pkgs; [
          libsigcxx
          stdenv.cc
          gnumake
          binutils
          ncurses5
          libGLU
          libGL
          pkg-config
          gcc-unwrapped
          clang
          ninja
          llvmPackages.libclang
          glibc_multi
          lld
          mold
          rustup
          # I would prefer to use a more declarative way, 
          # but Flutter Rust Bridge uses cargokit, 
          # and that calls directly rustup for handling of targets and compilation
        ];
        all_deps = with pkgs; [
          nixpkgs-fmt
          cmake
          protoc-gen-prost
          just
        ] ++ buildInputs ++ nativeBuildInputs ++ graphics ++ ml;
      in
      rec {
        devShell = pkgs.mkShell {

          nativeBuildInputs = all_deps;

          VULKAN_LIB_DIR="${pkgs.shaderc.dev}/lib";
          VULKAN_SDK="${pkgs.vulkan-validation-layers}/share/vulkan/explicit_layer.d";

          ANDROID_HOME = "${androidSdk}/libexec/android-sdk";
          ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
          ANDROID_NDK_ROOT = "${devShell.ANDROID_SDK_ROOT}/ndk-bundle";
          NDK_HOME="${devShell.ANDROID_HOME}/ndk/$(ls -1 ${devShell.ANDROID_HOME}/ndk)";

          FLUTTER_ROOT = "${pkgs.flutter}";

          GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${androidSdk}/libexec/android-sdk/build-tools/${buildToolsVersions}/aapt2";

          CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER = "${pkgs.llvmPackages.clangUseLLVM}/bin/clang";

          RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
          PATH = "~/.cargo/bin:$PATH"; # So that cargo binaries are available

          LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath all_deps}:${pkgs.ncurses5}/lib:${pkgs.stdenv.cc.cc.lib}/lib:${pkgs.gcc}/lib:${pkgs.cudaPackages.cudatoolkit}/lib:${pkgs.vulkan-loader}/lib:${pkgs.shaderc.lib}/lib:${pkgs.shaderc.dev}/lib";

          CUDA_PATH="${pkgs.cudatoolkit}";
          CUDA_HOME="${pkgs.cudatoolkit}";
          
          HF_HUB_ENABLE_HF_TRANSFER = 1;
          
          shellHook = ''
            export CARGO_MANIFEST_DIR=$(pwd) # This is declared here because it seems the project root is not accessible in the flake
            export LD_LIBRARY_PATH="$(pwd)/build/linux/x64/debug/bundle/lib:$(pwd)/build/linux/x64/release/bundle/lib:$LD_LIBRARY_PATH"
          ''; # That last line is so that dart can find the rust libs
        };
      }
    );
}