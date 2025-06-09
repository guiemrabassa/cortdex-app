
## Dynamic library not found (MacOS)
dyld[39595]: Library not loaded: /usr/local/lib/rust_lib_cortdex.dylib
  Referenced from: <SOME_UUID> /PATH_PREV_TO_CORTDEX/cortdex/build/macos/Build/Products/Debug/cortdex.app/Contents/MacOS/cortdex.debug.dylib
  Reason: tried: '/usr/local/lib/rust_lib_cortdex.dylib' (no such file), '/System/Volumes/Preboot/Cryptexes/OS/usr/local/lib/rust_lib_cortdex.dylib' (no such file), '/usr/local/lib/rust_lib_cortdex.dylib' (no such file)

[Source](https://cjycode.com/flutter_rust_bridge/manual/integrate/existing/ios/proj)

"Now, open up that $crate/$crate.xcodeproj file with Xcode and select the root item at the left pane. The item's name will be identical to your crate's name. In the Build Settings tab, search for Dynamic Library Install Name Base and change the value into @executable_path/../Frameworks/. This is required by cargo-xcode to enable macOS executable to properly locate .dylib library files in the package."


## Black screen on window (MacOS)
Does not fix it:
The workaround is to delete $FLUTTER_SDK$/bin/cache/ and rerun
[Source](https://github.com/flutter/flutter/issues/125025#issuecomment-1513295761)


## libc++_shared.so not found (Android)
https://github.com/fzyzcjy/flutter_rust_bridge/issues/883

Either from here: https://chromium.googlesource.com/android_tools/+/20ee6d20/ndk/sources/cxx-stl/llvm-libc++/libs
Or from a NDK (seems that 22 has them, but not newer ones...)  cxx-stl/llvm-libc++/libs

Only these targets:
- arm64-v8a
- armeabi-v7a
- x86
- x86_64/