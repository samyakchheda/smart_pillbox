import 'package:flutter/material.dart';
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
    setState(() {
      _messages = _chatService.messages;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// ✅ **Handles Sending Messages (Text or Image)**
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

  /// ✅ **Handles Uploading Image & Description**
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

  /// ✅ **Shows Dialog to Enter Image Description**
  Future<String> _showDescriptionDialog() async {
    TextEditingController descriptionController = TextEditingController();

    return await showDialog<String>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Describe the Image"),
              content: TextField(
                controller: descriptionController,
                decoration: InputDecoration(hintText: "Enter a description..."),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text("Cancel"),
                  onPressed: () => Navigator.pop(context, ""),
                ),
                TextButton(
                  child: Text("Submit"),
                  onPressed: () =>
                      Navigator.pop(context, descriptionController.text.trim()),
                ),
              ],
            );
          },
        ) ??
        "";
  }

  /// ✅ **Handles Audio Recording Start**
  Future<void> _startRecording() async {
    if (!_isGeneratingResponse && !_isRecording) {
      await _audioService.startRecording();
      setState(() => _isRecording = true);
    }
  }

  /// ✅ **Handles Audio Recording Stop & Transcription**
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

  /// ✅ **Handles Chat Navigation & Management**
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
      backgroundColor: Colors.grey[500], // Grey background for the whole screen
      appBar: AppBar(
        title: const Text('SmartDose ChatBot'),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            color: Colors.grey, // Maintain consistent color
          ),
        ),
      ),
      drawer: Sidebar(
        onNewChat: _startNewChat,
        savedChats: _chatService.savedChats,
        onChatSelected: _selectChat,
        onChatDeleted: _deleteChat,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white, // White background for chat screen
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40), // Rounded top-left corner
            topRight: Radius.circular(40), // Rounded top-right corner
          ),
        ),
        margin:
            const EdgeInsets.only(top: 10), // Adds spacing for rounded effect
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
    );
  }
}
