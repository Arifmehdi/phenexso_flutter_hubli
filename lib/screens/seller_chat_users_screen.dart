// lib/screens/seller_chat_users_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hubli/providers/chat_provider.dart';
import 'package:hubli/models/chat/user.dart' as chat_user; // Alias for chat User model
import 'package:hubli/screens/conversation_screen.dart';
import 'package:hubli/screens/search_users_screen.dart';
import 'package:hubli/providers/user_provider.dart';
import 'package:hubli/utils/api_constants.dart';

class SellerChatUsersScreen extends StatefulWidget {
  const SellerChatUsersScreen({super.key});

  @override
  State<SellerChatUsersScreen> createState() => _SellerChatUsersScreenState();
}

class _SellerChatUsersScreenState extends State<SellerChatUsersScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Fetch chat users for the user list
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (!userProvider.isLoading && userProvider.users.isEmpty && userProvider.errorMessage == null) {
      userProvider.fetchAllUsers();
    }
  }

  Future<void> _startChatWithUser(chat_user.User user) async { // Use chat_user.User
    try {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      final conversation = await chatProvider.getOrCreatePrivateConversation(user.id);
      if (conversation != null && mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ConversationScreen(
              conversationId: conversation.id,
              conversationTitle: user.name,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start chat: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Chats'), // Custom title for Seller Panel
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (userProvider.errorMessage != null) {
            return Center(child: Text('Error loading users: ${userProvider.errorMessage}'));
          }
          if (userProvider.users.isEmpty) {
            return const Center(child: Text('No chat users found.'));
          }

          return ListView.builder(
            itemCount: userProvider.users.length,
            itemBuilder: (context, index) {
              final user = userProvider.users[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: user.profilePhoto != null && user.profilePhoto!.isNotEmpty
                        ? NetworkImage('${ApiConstants.imageUploadsBaseUrl}${user.profilePhoto!}') as ImageProvider
                        : null,
                    child: user.profilePhoto == null || user.profilePhoto!.isEmpty
                        ? Text(user.name.isNotEmpty ? user.name[0] : '?')
                        : null,
                  ),
                  title: Text(user.name),
                  subtitle: Text(user.email ?? 'No email'),
                  onTap: () => _startChatWithUser(user),
                ),
              );
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