import 'dart:io';

class ChatMessage {
  final String text;
  final bool isUser;
  final File? file;
  final Map<String, dynamic>? metadata;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.file,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
        'text': text,
        'isUser': isUser,
        'filePath': file?.path,
        'metadata': metadata,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        text: json['text'],
        isUser: json['isUser'],
        file: json['filePath'] != null ? File(json['filePath']) : null,
        metadata: json['metadata'],
      );
}
