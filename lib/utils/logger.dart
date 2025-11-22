class Logger {
  static void add(String text) {
    final time = DateTime.now().toString().substring(11, 19);
    print('[$time] $text');
  }
}