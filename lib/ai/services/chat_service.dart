import 'dart:convert';
import 'dart:io';
import 'image_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_message.dart';

class ChatService {
  List<ChatMessage> _messages = [];
  List<String> _savedChats = [];
  String _currentChatId = '';
  SharedPreferences? _prefs;

  List<ChatMessage> get messages => _messages;
  List<String> get savedChats => _savedChats;
  final ScrollController _scrollController = ScrollController();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _currentChatId = const Uuid().v4();
    await _loadChatHistory();
    _loadSavedChats();
  }

  void _loadSavedChats() {
    if (_prefs == null) return;
    _savedChats = _prefs!.getStringList('savedChats') ?? [];
  }

  void _saveChatList() {
    if (_prefs == null) return;
    _prefs!.setStringList('savedChats', _savedChats);
  }

  Future<void> _loadChatHistory() async {
    if (_prefs == null) return;
    String? chatHistory = _prefs!.getString(_currentChatId);
    if (chatHistory != null) {
      List<dynamic> decodedHistory = jsonDecode(chatHistory);
      _messages =
          decodedHistory.map((item) => ChatMessage.fromJson(item)).toList();
    }
  }

  Future<void> _saveChatHistory() async {
    if (_prefs == null) return;
    List<Map<String, dynamic>> encodedHistory =
        _messages.map((message) => message.toJson()).toList();
    await _prefs!.setString(_currentChatId, jsonEncode(encodedHistory));
  }

  /// ✅ **Scrolls Chat to Bottom**
  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> sendMessage({String? text, File? file}) async {
    if ((text == null || text.isEmpty) && file == null) return;

    ChatMessage message;

    if (file != null) {
      String fileName = file.path.split('/').last;

      message = ChatMessage(
        text: 'Sent an image: $fileName\nDescription: $text',
        isUser: true,
        file: file,
      );

      _messages.insert(0, message);
      await _saveChatHistory();

      // 🔥 Process image with the given description
      String? response =
          await ImageService().processImageWithGemini(file, text!);

      _messages.insert(
        0,
        ChatMessage(
          text: response ?? "Could not analyze the image.",
          isUser: false,
        ),
      );
    } else {
      message = ChatMessage(
        text: text!,
        isUser: true,
      );

      _messages.insert(0, message);
      await _saveChatHistory();

      String response = await _getGeminiResponse(message);

      _messages.insert(
        0,
        ChatMessage(
          text: response,
          isUser: false,
        ),
      );
    }

    await _saveChatHistory();
    scrollToBottom();
  }

  Future<String> _getGeminiResponse(ChatMessage message) async {
    try {
      const assistantInfo = '''
      You are a health assistant. Answer all questions with a focus on health-related information.
      Your name is SmartDose.
      You were developed by - Mr. Samyak Chheda, Mr. Parth Dave, Mr. Rishi Vejani.
      ''';

      String prompt = assistantInfo;

      for (var i = _messages.length - 1;
          i >= 0 && i > _messages.length - 6;
          i--) {
        prompt +=
            '\n${_messages[i].isUser ? "User" : "Assistant"}: ${_messages[i].text}';
      }

      prompt += '\nUser: ${message.text}';

      if (message.file != null) {
        String fileContent = await message.file!.readAsString();
        prompt += '\nAttached file content: $fileContent';
      }

      final isHealthRelated = await Gemini.instance.prompt(parts: [
        Part.text(
            "Is the following prompt related to health? Answer with 'yes' or 'no':\n$prompt"),
      ]);

      if (isHealthRelated?.output?.trim().toLowerCase() == 'yes') {
        final response = await Gemini.instance.prompt(parts: [
          Part.text(prompt),
        ]);
        return response?.output ?? 'No response from Gemini.';
      } else {
        return "I'm sorry, but I can only respond to health-related questions. Please ask a question about health or medical topics.";
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

  void startNewChat() {
    _messages.clear();
    _currentChatId = const Uuid().v4();
    if (!_savedChats.contains(_currentChatId)) {
      _savedChats.add(_currentChatId);
      _saveChatList();
    }
    _saveChatHistory();
  }

  void selectChat(String chatId) {
    _currentChatId = chatId;
    _loadChatHistory();
  }

  void deleteChat(String chatId) {
    _savedChats.remove(chatId);
    _prefs!.remove(chatId);
    _saveChatList();
  }
}
