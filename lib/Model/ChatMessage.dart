import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String from;
  final String to;
  final String content;
  final Timestamp timestamp;

  ChatMessage({
    required this.from,
    required this.to,
    required this.content,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'from': from,
      'to': to,
      'content': content,
      'timestamp': timestamp,
    };
  }
  factory ChatMessage.fromDocument(DocumentSnapshot doc) {
    return ChatMessage(
      from: doc['from'],
      to: doc['to'],
      content: doc['content'],
      timestamp: doc['timestamp'],
    );
  }
}
