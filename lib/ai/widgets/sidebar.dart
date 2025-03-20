import 'package:flutter/material.dart';
import 'package:home/theme/app_colors.dart';

class Sidebar extends StatelessWidget {
  final VoidCallback onNewChat;
  final List<String> savedChats;
  final Function(String) onChatSelected;
  final Function(String) onChatDeleted;

  const Sidebar({
    Key? key,
    required this.onNewChat,
    required this.savedChats,
    required this.onChatSelected,
    required this.onChatDeleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.buttonColor,
                  Colors.grey.shade400
                ], // Replace with your gradient colors
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Text(
              'SmartDose',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.chat),
            title: const Text('New Chat'),
            onTap: () {
              onNewChat();
              Navigator.pop(context);
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Saved Conversations',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ...savedChats.map((chatId) => ListTile(
                title: Text('Chat $chatId'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => onChatDeleted(chatId),
                ),
                onTap: () {
                  onChatSelected(chatId);
                  Navigator.pop(context);
                },
              )),
        ],
      ),
    );
  }
}
