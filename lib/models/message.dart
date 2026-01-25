import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String receiverId;
  final String message;
  final Timestamp timestamp;
  final String? fileUrl;
  final String? fileName;
  final String? fileType;

  Message({
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    this.fileUrl,
    this.fileName,
    this.fileType,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'fileType': fileType,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderId: map['senderId'],
      receiverId: map['receiverId'],
      message: map['message'],
      timestamp: map['timestamp'],
      fileUrl: map['fileUrl'],
      fileName: map['fileName'],
      fileType: map['fileType'],
    );
  }
}
