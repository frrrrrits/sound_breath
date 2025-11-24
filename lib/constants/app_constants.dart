import 'dart:io';

class AppConstants {
  static const int tcpPort = 4040;
  static const int httpPort = 8080;
  static const String defaultIpAddress = '192.168.1.1';
  static final bool isMobile = Platform.isIOS && Platform.isAndroid;
}
