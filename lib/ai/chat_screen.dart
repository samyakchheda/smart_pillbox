import 'package:flutter/material.dart';
import 'package:home/theme/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import './widgets/message_composer.dart';
import './widgets/message_list.dart';
import './widgets/typing_indicator.dart';
import './widgets/sidebar.dart';
import './models/chat_message.dart';
import './services/chat_service.dart';
import './services/audio_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

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

    // Start a new chat first
    _startNewChat();

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
          "Hello! I'm SmartDose, your health assistant. How can I help you today with your health-related questions?",
    );

    // If your ChatService provides a method to add a message, use it:
    // _chatService.addMessage(aiMessage);
    //
    // Otherwise, directly add to the messages list:
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
              title: const Text("Describe the Image"),
              content: TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  hintText: "Enter a description...",
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () => Navigator.pop(context, ""),
                ),
                TextButton(
                  child: const Text("Submit"),
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

  void _startNewChat() {
    _chatService.startNewChat();
    setState(() => _messages = _chatService.messages);
  }

  void _selectChat(String chatId) {
    _chatService.selectChat(chatId);
    setState(() => _messages = _chatService.messages);
  }

  void _deleteChat(String chatId) {
    _chatService.deleteChat(chatId);
    setState(() {});
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
      drawer: Sidebar(
        onNewChat: _startNewChat,
        savedChats: _chatService.savedChats,
        onChatSelected: _selectChat,
        onChatDeleted: _deleteChat,
      ),
      body: Stack(
        children: [
          Container(
            height: 250,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.buttonColor,
                  Colors.grey.shade400,
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
                    Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(Icons.menu, color: Colors.black),
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                      ),
                    ),
                    const Text(
                      'ChatBot',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black),
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
                    color: const Color(0xFFE0E0E0),
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
