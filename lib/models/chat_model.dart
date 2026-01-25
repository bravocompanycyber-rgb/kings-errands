import 'package:kings_errands/models/user_model.dart';

class ChatModel {
  final String id;
  final List<UserModel> participants;
  final String lastMessage;
  final DateTime timestamp;

  ChatModel({
    required this.id,
    required this.participants,
    required this.lastMessage,
    required this.timestamp,
  });
}
