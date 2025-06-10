build *ARGS:
    @~/.cargo/bin/flutter_rust_bridge_codegen generate {{ARGS}}

build-rust-watch: (build "--watch")

run: build
    @flutter run

run-no-build:
    @flutter run

codegen *ARGS:
    @dart run build_runner build {{ARGS}}

codegen-watch: (codegen "watch")

test *ARGS:
    @cargo run --manifest-path rust/test/Cargo.toml {{ARGS}}

fix-libc:
    cp -r $NDK_HOME/sources/cxx-stl/llvm-libc++/libs/* ./android/app/src/main/jniLibs

android:
    @flutter build apk --target-platform android-arm64

android-release: android
    @flutter install
