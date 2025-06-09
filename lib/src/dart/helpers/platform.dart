import 'dart:io';


abstract final class PlatformUtils {

  @pragma("vm:platform-const")
  static final bool isMobile = (Platform.isAndroid || Platform.isIOS);

  @pragma("vm:platform-const")
  static final bool isDesktop = !isMobile; 

}