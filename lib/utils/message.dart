class Message {
  final String text;
  final bool isMe;
  final DateTime timestamp;

  Message({required this.text, required this.isMe})
      : timestamp = DateTime.now();

  @override
  String toString() => '${isMe ? 'You' : 'Other'} [${timestamp.toString().substring(11, 19)}]: $text';
}