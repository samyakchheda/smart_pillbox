import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:home/theme/app_colors.dart';
import '../../models/chat_message.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/theme_provider.dart';

class MessageBubble extends StatefulWidget {
  final ChatMessage message;

  const MessageBubble({Key? key, required this.message}) : super(key: key);

  @override
  _MessageBubbleState createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  // Static set to remember which messages have already been animated during runtime.
  static final Set<String> _animatedMessages = {};
  // Persisted set loaded from SharedPreferences.
  static Set<String> _persistentAnimatedMessages = {};

  bool _animationCompleted = false;

  String? _username;
  bool _loadingUsername = true;

  @override
  void initState() {
    super.initState();
    _loadPersistentAnimatedMessages().then((_) {
      // Check if this message was animated in a previous session.
      if (_persistentAnimatedMessages.contains(widget.message.text)) {
        setState(() {
          _animationCompleted = true;
        });
      }
    });
    _loadPersistentAnimatedMessages();
    _fetchUsername();
  }

  Future<void> _fetchUsername() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      try {
        final doc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
        setState(() {
          _username = doc.data()?['name'] as String? ?? 'Unknown';
        });
      } catch (e) {
        setState(() => _username = 'Unknown');
      }
    } else {
      setState(() => _username = 'Unknown');
    }
    setState(() => _loadingUsername = false);
  }

  Future<void> _loadPersistentAnimatedMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final messagesList = prefs.getStringList('animatedMessages') ?? [];
    _persistentAnimatedMessages = messagesList.toSet();
  }

  Future<void> _updatePersistentAnimatedMessages(String messageText) async {
    _persistentAnimatedMessages.add(messageText);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        'animatedMessages', _persistentAnimatedMessages.toList());
  }

  @override
  void didUpdateWidget(covariant MessageBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When a new message arrives, check if it has been animated before.
    if (oldWidget.message.text != widget.message.text) {
      _animationCompleted = _animatedMessages.contains(widget.message.text) ||
          _persistentAnimatedMessages.contains(widget.message.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeProvider.themeNotifier,
      builder: (context, themeMode, child) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
          child: Row(
            mainAxisAlignment: widget.message.isUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!widget.message.isUser) ...[
                CircleAvatar(
                  backgroundColor: AppColors.buttonColor,
                  child: const Text('SD'),
                  foregroundColor: AppColors.textOnPrimary,
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: widget.message.isUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.message.isUser
                          ? (_loadingUsername ? '…' : (_username ?? 'Unknown'))
                          : 'SmartDose',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.borderColor,
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.borderColor.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: widget.message.isUser
                          ? _buildUserMessage()
                          : _buildAnimatedMessage(),
                    ),
                  ],
                ),
              ),
              if (widget.message.isUser) ...[
                const SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: AppColors.kBlackColor,
                  foregroundColor: AppColors.textOnPrimary,
                  child: Text(
                    // while we’re still loading, show a placeholder
                    _loadingUsername
                        ? '…'
                        // once loaded, use the first letter or '?' if somehow empty
                        : (_username != null && _username!.isNotEmpty
                            ? _username![0].toUpperCase()
                            : '?'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimatedMessage() {
    // If animation hasn't completed, show the animated text.
    if (!_animationCompleted) {
      return AnimatedTextKit(
        key: ValueKey(widget.message.text),
        animatedTexts: [
          TypewriterAnimatedText(
            widget.message.text,
            textStyle: TextStyle(
              fontSize: 16.0,
              color: AppColors.textPrimary,
            ),
            speed: const Duration(milliseconds: 25),
          ),
        ],
        isRepeatingAnimation: false,
        totalRepeatCount: 1,
        displayFullTextOnTap: true,
        onFinished: () {
          // Mark animation as complete and store it in our static set and persistent storage.
          setState(() {
            _animationCompleted = true;
            _animatedMessages.add(widget.message.text);
          });
          _updatePersistentAnimatedMessages(widget.message.text);
        },
      );
    }
    // If animation is already done, simply display the static text.
    return Text(
      widget.message.text,
      style: TextStyle(
        fontSize: 16.0,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildUserMessage() {
    if (widget.message.file != null) {
      final filePath = widget.message.file!.path.toLowerCase();
      if (filePath.endsWith('.jpg') ||
          filePath.endsWith('.jpeg') ||
          filePath.endsWith('.png')) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.file(
              widget.message.file!,
              height: 150,
              width: 150,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 5),
            Text(
              widget.message.text,
              style: TextStyle(
                fontSize: 16.0,
                color: AppColors.textPrimary,
              ),
            ),
            if (widget.message.metadata != null &&
                widget.message.metadata!['description'] != null)
              Text(
                'Description: ${widget.message.metadata!['description']}',
                style: TextStyle(
                  fontSize: 14.0,
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        );
      } else if (filePath.endsWith('.aac')) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.audio_file,
              size: 50,
              color: AppColors.buttonColor,
            ),
            const SizedBox(height: 5),
            Text(
              widget.message.text,
              style: TextStyle(
                fontSize: 16.0,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        );
      }
    }
    return Text(
      widget.message.text,
      style: TextStyle(
        fontSize: 16.0,
        color: AppColors.textPrimary,
      ),
    );
  }
}
