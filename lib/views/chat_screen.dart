import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:kings_errands/models/message.dart';
import 'package:path_provider/path_provider.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  const ChatScreen({super.key, required this.receiverId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _firestore
          .collection('chats')
          .doc(_getChatRoomId())
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final messages = snapshot.data!.docs
            .map((doc) => Message.fromMap(doc.data()))
            .toList();
        return ListView.builder(
          reverse: true,
          itemCount: messages.length,
          itemBuilder: (context, index) => _buildMessageItem(messages[index]),
        );
      },
    );
  }

  Widget _buildMessageItem(Message message) {
    final isCurrentUser = message.senderId == _auth.currentUser!.uid;
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Card(
        color: isCurrentUser
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.secondary,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.message,
                style: const TextStyle(color: Colors.white),
              ),
              if (message.fileUrl != null)
                GestureDetector(
                  onTap: () =>
                      _downloadFile(message.fileUrl!, message.fileName!),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.file_present, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        message.fileName!,
                        style: const TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          IconButton(onPressed: _pickFile, icon: const Icon(Icons.attach_file)),
          IconButton(onPressed: _pickImage, icon: const Icon(Icons.image)),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(hintText: 'Enter message...'),
            ),
          ),
          IconButton(onPressed: _sendMessage, icon: const Icon(Icons.send)),
        ],
      ),
    );
  }

  String _getChatRoomId() {
    final userIds = [_auth.currentUser!.uid, widget.receiverId];
    userIds.sort();
    return userIds.join('_');
  }

  void _sendMessage({
    String? fileUrl,
    String? fileName,
    String? fileType,
  }) async {
    if (_messageController.text.isEmpty && fileUrl == null) return;

    final message = Message(
      senderId: _auth.currentUser!.uid,
      receiverId: widget.receiverId,
      message: _messageController.text,
      timestamp: Timestamp.now(),
      fileUrl: fileUrl,
      fileName: fileName,
      fileType: fileType,
    );

    await _firestore
        .collection('chats')
        .doc(_getChatRoomId())
        .collection('messages')
        .add(message.toMap());
    _messageController.clear();
  }

  void _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      _uploadFile(File(result.files.single.path!));
    }
  }

  void _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      _uploadFile(File(pickedFile.path));
    }
  }

  void _uploadFile(File file) async {
    final fileName = file.path.split('/').last;
    final ref = _storage.ref().child('chat_files/$fileName');
    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask.whenComplete(() {});
    final fileUrl = await snapshot.ref.getDownloadURL();

    _sendMessage(
      fileUrl: fileUrl,
      fileName: fileName,
      fileType: fileName.split('.').last,
    );
  }

  Future<void> _downloadFile(String url, String fileName) async {
    try {
      final ref = _storage.refFromURL(url);
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);

      await ref.writeToFile(file);

      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Downloaded $fileName to $filePath')),
        );
      }
    } catch (e) {
      if(mounted){
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error downloading file: $e')));
      }
    }
  }
}
