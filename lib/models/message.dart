import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  const Message({
    required this.senderID,
    required this.senderEmail,
    required this.receiverID,
    required this.message,
    required this.timestamp,
    this.audioUrl,
  });

  final String senderID;
  final String senderEmail;
  final String receiverID;
  final String? message;
  final Timestamp timestamp;
  final String? audioUrl;

  // Convert to map
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'senderId': senderID,
      'senderEmail': senderEmail,
      'receiverID': receiverID,
      'timestamp': timestamp,
    };

    if (message != null) {
      map['message'] = message!;
    }

    // Include audioUrl if it's not null
    if (audioUrl != null) {
      map['audioUrl'] = audioUrl!;
    }

    return map;
  }

  // Factory method to create a Message instance from a map
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderID: map['senderId'],
      senderEmail: map['senderEmail'],
      receiverID: map['receiverID'],
      message: map['message'] as String?,
      timestamp: map['timestamp'],
      audioUrl: map['audioUrl'] as String?, // Handle null value gracefully
    );
  }
}
