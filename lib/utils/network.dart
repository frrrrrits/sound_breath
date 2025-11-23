import 'dart:io';

class Network {
  static Future<String> getMyIp() async {
    for (var interface in await NetworkInterface.list()) {
      for (var addr in interface.addresses) {
        if (!addr.isLoopback && addr.type == InternetAddressType.IPv4) {
          return addr.address;
        }
      }
    }
    return 'localhost';
  }

  static Future<String> getLocalIp() async {
    for (var interface in await NetworkInterface.list()) {
      for (var addr in interface.addresses) {
        if (addr.type == InternetAddressType.IPv4 &&
            !addr.address.startsWith("169")) {
          return addr.address;
        }
      }
    }
    return "0.0.0.0";
  }
}
