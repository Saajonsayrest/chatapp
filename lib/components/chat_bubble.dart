import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:messenger_app/themes/theme_provider.dart';
import 'package:provider/provider.dart';

class ChatBubble extends StatefulWidget {
  final String message;
  final bool isCurrentUser;
  final String? audioUrl;

  const ChatBubble({
    Key? key,
    required this.message,
    required this.isCurrentUser,
    this.audioUrl,
  }) : super(key: key);

  @override
  _ChatBubbleState createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      if (widget.audioUrl != null) {
        await _audioPlayer.setUrl(widget.audioUrl!);
        await _audioPlayer.play();
      }
    }

    setState(() {
      _isPlaying = !_isPlaying;
    });

    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        setState(() {
          _isPlaying = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(15, 5, 15, 0),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: widget.isCurrentUser
            ? Colors.green.shade600 // Green for current user
            : Colors.grey.shade300, // Grey for other user
        borderRadius: widget.isCurrentUser
            ? const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
          bottomLeft: Radius.circular(12),
        ) // Rounded corners for the current user's message
            : const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ), // Rounded corners for the other user's message
      ),
      child: widget.audioUrl != null
          ? _buildAudioBubble()
          : Text(
        widget.message,
        style: TextStyle(
          color: widget.isCurrentUser ? Colors.white : Colors.black, // White text for current user, black for other user
        ),
      ),
    );
  }


  Widget _buildAudioBubble() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white),
          onPressed: _togglePlayPause,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Audio Message',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

