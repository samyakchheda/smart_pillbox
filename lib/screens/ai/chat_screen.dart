import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:home/models/chat_message.dart';
import 'package:home/services/ai_service/audio_service.dart';
import 'package:home/services/ai_service/chat_service.dart';
import 'package:home/theme/app_colors.dart';
import 'package:home/widgets/ai/message_composer.dart';
import 'package:home/widgets/ai/message_list.dart';
import 'package:home/widgets/ai/typing_indicator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final AudioService _audioService = AudioService();

  List<ChatMessage> _messages = [];
  bool _isRecording = false;
  bool _isTyping = false;
  bool _isGeneratingResponse = false;

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<void> _initServices() async {
    await _chatService.init();
    await _audioService.initialize();

    // Optionally wait a moment to ensure the chat is reset
    await Future.delayed(const Duration(milliseconds: 100));

    // Add the AI info message
    _sendAiInfoMessage();

    // Update local state
    setState(() {
      _messages = _chatService.messages;
    });
  }

  void _sendAiInfoMessage() {
    // Create an AI info message
    final aiMessage = ChatMessage(
      isUser: false,
      text:
          "Hello! I'm SmartDose, your health assistant. How can I help you today with your health-related questions?"
              .tr(),
    );

    // Add to the messages list via ChatService
    _chatService.messages.add(aiMessage);

    // Update the state so the message is displayed
    setState(() {
      _messages = _chatService.messages;
    });
  }

  void _sendMessage({String? text, File? file}) async {
    if ((text == null || text.trim().isEmpty) && file == null) return;

    setState(() {
      _isTyping = true;
      _isGeneratingResponse = true;
    });

    await _chatService.sendMessage(text: text, file: file);

    setState(() {
      _messages = _chatService.messages;
      _isTyping = false;
      _isGeneratingResponse = false;
    });
  }

  Future<void> _uploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File image = File(pickedFile.path);
      String description = await _showDescriptionDialog();
      _sendMessage(text: description, file: image);
    }
  }

  Future<String> _showDescriptionDialog() async {
    TextEditingController descriptionController = TextEditingController();

    return await showDialog<String>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: AppColors.cardBackground,
              title: Text(
                "Describe the Image".tr(),
                style: TextStyle(color: AppColors.textPrimary),
              ),
              content: TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  hintText: "Enter a description...".tr(),
                  hintStyle: TextStyle(color: AppColors.textPlaceholder),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.buttonColor),
                  ),
                ),
                style: TextStyle(color: AppColors.textPrimary),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    "Cancel".tr(),
                    style: TextStyle(color: AppColors.buttonColor),
                  ),
                  onPressed: () => Navigator.pop(context, ""),
                ),
                TextButton(
                  child: Text(
                    "Submit".tr(),
                    style: TextStyle(color: AppColors.buttonColor),
                  ),
                  onPressed: () =>
                      Navigator.pop(context, descriptionController.text.trim()),
                ),
              ],
            );
          },
        ) ??
        "";
  }

  Future<void> _startRecording() async {
    if (!_isGeneratingResponse && !_isRecording) {
      await _audioService.startRecording();
      setState(() => _isRecording = true);
    }
  }

  Future<void> _stopRecording() async {
    if (_isRecording) {
      String transcribedText = await _audioService.stopRecording();
      setState(() => _isRecording = false);
      _sendMessage(
          text: transcribedText.isNotEmpty
              ? transcribedText
              : 'Failed to transcribe speech');
    }
  }

  void _stopResponseGeneration() {
    setState(() {
      _isGeneratingResponse = false;
      _isTyping = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Container(
            height: 250,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.buttonColor,
                  AppColors.borderColor,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Column(
            children: [
              Container(
                height: 150,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          'ChatBot'.tr(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textOnPrimary,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: MessageList(
                          messages: _messages,
                        ),
                      ),
                      if (_isTyping) const TypingIndicator(),
                      MessageComposer(
                        onSendMessage: _sendMessage,
                        onImagePicked: _uploadImage,
                        onRecordingStarted: _startRecording,
                        onRecordingStopped: _stopRecording,
                        isGeneratingResponse: _isGeneratingResponse,
                        onStopResponseGeneration: _stopResponseGeneration,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
