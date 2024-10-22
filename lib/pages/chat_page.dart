import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:messenger_app/components/chat_bubble.dart';
import 'package:messenger_app/components/my_textfield.dart';
import 'package:messenger_app/services/auth/auth_service.dart';
import 'package:messenger_app/services/chat/chat_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ChatPage extends StatefulWidget {
  const ChatPage(
      {super.key, required this.receiverEmail, required this.receiverID});

  final String receiverEmail;
  final String receiverID;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final AuthService _authService = AuthService();
  final ChatService _chatService = ChatService();
  final _audioRecorder = AudioRecorder();

  FocusNode myFocusNode = FocusNode();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String? _audioPath;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 300), () => scrollDown());
      }
    });
    Future.delayed(const Duration(milliseconds: 300), () => scrollDown());
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
    );
  }

  // Start recording audio
  Future<void> startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      final directory = await getApplicationDocumentsDirectory();
      final String filePath =
          '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder.start(const RecordConfig(), path: filePath);
      setState(() {
        _audioPath = filePath;
        _isRecording = true;
      });
      print('👀Recording started. Path: $_audioPath'); // Debug statement
    } else {
      print('👀No permission to record audio.'); // Debug statement
    }
  }

  // Stop recording audio
  Future<void> stopRecording() async {
    if (_isRecording) {
      _audioPath = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
      });
      print('👀Recording stopped. File saved at: $_audioPath'); // Debug statement
    } else {
      print('👀Recording was not active.'); // Debug statement
    }
  }

  // Send only text message
  Future<void> sendTextMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
        receiverID: widget.receiverID,
        message: _messageController.text,
      );

      _messageController.clear();
    }
    scrollDown();
  }

// Send audio message
  Future<void> sendAudioMessage() async {
    if (_audioPath != null) {
      File audioFile = File(_audioPath!);
      await _chatService.sendMessage(
          receiverID: widget.receiverID, audioFile: audioFile);
      _audioPath = null;
      scrollDown();
    }
  }

// Handle long press gesture for recording and sending audio
  void handleLongPress() async {
    await startRecording(); // Just await the function, don't assign it to anything
  }

  void handleLongPressEnd(LongPressEndDetails details) async {
    await stopRecording();
    await sendAudioMessage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverEmail),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Display messages
          Expanded(
            child: _buildMessageList(),
          ),
          // User input
          _buildUserInput()
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    String senderID = _authService.getCurrentUser()!.uid;
    return StreamBuilder(
      stream: _chatService.getMessages(widget.receiverID, senderID),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error loading messages');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return ListView(
            controller: _scrollController,
            children: snapshot.data!.docs
                .map((doc) => _buildMessageItem(doc))
                .toList(),
          );
        }
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool isCurrentUser = data['senderId'] == _authService.getCurrentUser()!.uid;

    print('Document data: $data'); // Debug statement to see the entire document
    print('Current user ID: ${_authService.getCurrentUser()!.uid}'); // Debug statement to see the entire document

    return Container(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ChatBubble(
        message: data['message'] ?? '',
        isCurrentUser: isCurrentUser,
        audioUrl: data['audioUrl'], // Ensure audio URL is passed correctly
      ),
    );
  }


  Widget _buildUserInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 10),
      child: Row(
        children: [
          Expanded(
            child: MyTextField(
              hintText: 'Type a message',
              controller: _messageController,
              focusNode: myFocusNode,
            ),
          ),
          // Send Text Button (optional)
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: sendTextMessage,
            color: Colors.green,
          ),
          // Long press to record and send audio
          GestureDetector(
            onLongPress: handleLongPress,
            onLongPressEnd: handleLongPressEnd,
            child: Container(
              margin: const EdgeInsets.only(left: 10, right: 20),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(
                _isRecording ? Icons.mic : Icons.mic_none,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
