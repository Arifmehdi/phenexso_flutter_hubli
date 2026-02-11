// lib/screens/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hubli/providers/chat_provider.dart';
import 'package:hubli/models/chat/conversation.dart';
import 'package:hubli/screens/conversation_screen.dart';
import 'package:hubli/screens/search_users_screen.dart'; // Add this import
import 'package:hubli/providers/auth_provider.dart'; // Import AuthProvider for user ID

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatProvider>(context, listen: false).fetchConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          if (chatProvider.isLoadingConversations) {
            return const Center(child: CircularProgressIndicator());
          }
          if (chatProvider.errorMessage != null) {
            return Center(child: Text('Error: ${chatProvider.errorMessage}'));
          }
          if (chatProvider.conversations.isEmpty) {
            return const Center(child: Text('No conversations yet.'));
          }

          return ListView.builder(
            itemCount: chatProvider.conversations.length,
            itemBuilder: (context, index) {
              final conversation = chatProvider.conversations[index];
              return ConversationListItem(conversation: conversation);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const SearchUsersScreen()),
          );
        },
        child: const Icon(Icons.add_comment),
      ),
    );
  }
}

class ConversationListItem extends StatelessWidget {
  final Conversation conversation;

  const ConversationListItem({super.key, required this.conversation});

  @override
  Widget build(BuildContext context) {
    String title = conversation.title ?? 'New Conversation';
    // Access current authenticated user's ID
    final currentUserId = Provider.of<AuthProvider>(context, listen: false).user?.id;

    if (conversation.type == 'private' && conversation.participants.length >= 2) {
      // Find the other participant's name
      final otherParticipant = conversation.participants.firstWhere(
        (p) => p.userId != currentUserId,
        orElse: () => conversation.participants.first, // Fallback if only one participant or user not found
      );
      title = otherParticipant.user?.name ?? 'Private Chat';
    }

    final latestMessage = conversation.latestMessage;
    final lastMessageText = latestMessage != null
        ? '${latestMessage.sender?.name ?? 'Unknown'}: ${latestMessage.message}'
        : 'No messages yet';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
          child: Icon(
            conversation.type == 'private' ? Icons.person : Icons.group,
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Text(title),
        subtitle: Text(
          lastMessageText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: conversation.unreadCount > 0
            ? CircleAvatar(
                radius: 12,
                backgroundColor: Theme.of(context).hintColor,
                child: Text(
                  conversation.unreadCount.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              )
            : null,
        onTap: () {
          Provider.of<ChatProvider>(context, listen: false).setCurrentConversation(conversation);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ConversationScreen(
                conversationId: conversation.id,
                conversationTitle: title,
              ),
            ),
          );
        },
      ),
    );
  }
}