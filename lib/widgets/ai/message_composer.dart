import 'package:flutter/material.dart';
import 'dart:io';
import 'package:home/theme/app_colors.dart';
import 'package:home/theme/theme_provider.dart';

class MessageComposer extends StatefulWidget {
  final Function({String? text, File? file}) onSendMessage;
  final Function() onImagePicked;
  final Function() onRecordingStarted;
  final Function() onRecordingStopped;
  final bool isGeneratingResponse;
  final Function() onStopResponseGeneration;

  const MessageComposer({
    super.key,
    required this.onSendMessage,
    required this.onImagePicked,
    required this.onRecordingStarted,
    required this.onRecordingStopped,
    required this.isGeneratingResponse,
    required this.onStopResponseGeneration,
  });

  @override
  State<MessageComposer> createState() => _MessageComposerState();
}

class _MessageComposerState extends State<MessageComposer>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  bool _isRecording = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 1.0,
      upperBound: 1.3,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeProvider.themeNotifier,
      builder: (context, themeMode, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            boxShadow: [
              BoxShadow(
                offset: const Offset(0, -2),
                blurRadius: 4,
                color: AppColors.borderColor.withOpacity(0.1),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.photo),
                onPressed:
                    widget.isGeneratingResponse ? null : widget.onImagePicked,
                color: AppColors.buttonColor,
              ),
              GestureDetector(
                onLongPressStart: (LongPressStartDetails details) {
                  if (!widget.isGeneratingResponse && !_isRecording) {
                    setState(() {
                      _isRecording = true;
                    });
                    widget.onRecordingStarted(); // Start recording
                    _animationController
                        .forward(); // Animate the mic icon to pop
                  }
                },
                onLongPressEnd: (_) {
                  if (_isRecording) {
                    setState(() {
                      _isRecording = false;
                    });
                    widget.onRecordingStopped(); // Stop recording
                    _animationController.reverse(); // Reverse the mic animation
                  }
                },
                child: ScaleTransition(
                  scale: _animationController, // Scaling animation for the icon
                  child: IconButton(
                    icon: Icon(_isRecording
                        ? Icons.stop
                        : Icons
                            .mic), // Change icon depending on recording state
                    color: _isRecording
                        ? AppColors.errorColor
                        : AppColors.buttonColor, // Change icon color
                    onPressed: () {},
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Send a message...',
                    hintStyle: TextStyle(color: AppColors.textPlaceholder),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppColors.listItemBackground,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  style: TextStyle(color: AppColors.textPrimary),
                  onSubmitted: widget.isGeneratingResponse
                      ? null
                      : (text) {
                          if (text.trim().isNotEmpty) {
                            widget.onSendMessage(text: text);
                            _controller
                                .clear(); // Clear the text field after sending
                          }
                        },
                  enabled: !widget.isGeneratingResponse,
                ),
              ),
              IconButton(
                icon:
                    Icon(widget.isGeneratingResponse ? Icons.stop : Icons.send),
                onPressed: widget.isGeneratingResponse
                    ? widget.onStopResponseGeneration
                    : () {
                        if (_controller.text.trim().isNotEmpty) {
                          widget.onSendMessage(text: _controller.text);
                          _controller
                              .clear(); // Clear the text field after sending
                        }
                      },
                color: AppColors.buttonColor,
              ),
            ],
          ),
        );
      },
    );
  }
}
