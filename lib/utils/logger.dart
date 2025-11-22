class Logger {
  static void add(String text) {
    final time = DateTime.now().toString().substring(11, 19);
    // ignore: avoid_print
    print('[$time] $text');
  }
}