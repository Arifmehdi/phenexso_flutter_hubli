// lib/screens/conversation_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hubli/providers/chat_provider.dart';
import 'package:hubli/models/chat/message.dart';
import 'package:hubli/widgets/chat/chat_bubble.dart';
import 'package:hubli/widgets/chat/message_input.dart';
import 'package:image_picker/image_picker.dart'; // Import ImagePicker
import 'dart:io'; // Import for File

class ConversationScreen extends StatefulWidget {
  final int conversationId;
  final String conversationTitle;

  const ConversationScreen({
    super.key,
    required this.conversationId,
    required this.conversationTitle,
  });

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final ImagePicker _picker = ImagePicker(); // ImagePicker instance
  final ScrollController _scrollController = ScrollController(); // ScrollController for message list
  
  // Track previous message count to know when new messages arrive
  int _previousMessageCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatProvider>(context, listen: false)
          .fetchMessages(widget.conversationId);
    });

    // Add a listener to ChatProvider for new messages
    Provider.of<ChatProvider>(context, listen: false).addListener(_onChatProviderChange);
  }

  void _onChatProviderChange() {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    if (chatProvider.currentMessages.length > _previousMessageCount &&
        _scrollController.hasClients) {
      _scrollToBottom();
    }
    _previousMessageCount = chatProvider.currentMessages.length;
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0, // Because reverse: true, 0.0 is the bottom
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // Method to pick an image and send it
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // Send the image as a message
      if (mounted) {
        await Provider.of<ChatProvider>(context, listen: false).sendMessage(
          widget.conversationId,
          messageType: 'image', // Set message type to 'image'
          file: File(image.path), // Pass the file
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.conversationTitle),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                if (chatProvider.isLoadingMessages) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (chatProvider.errorMessage != null) {
                  return Center(
                      child: Text('Error: ${chatProvider.errorMessage}'));
                }
                if (chatProvider.currentMessages.isEmpty) {
                  return const Center(child: Text('No messages yet. Say hello!'));
                }

                return ListView.builder(
                  reverse: true, // Display latest messages at the bottom
                  controller: _scrollController, // Attach controller
                  itemCount: chatProvider.currentMessages.length,
                  itemBuilder: (context, index) {
                    final message = chatProvider.currentMessages[
                        chatProvider.currentMessages.length - 1 - index]; // Reverse order
                    return ChatBubble(message: message);
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SafeArea( // Ensures the input is not obscured by system UI (e.g., gesture navigation)
              child: MessageInput(
                onSendMessage: (text) {
                  Provider.of<ChatProvider>(context, listen: false).sendMessage(
                    widget.conversationId,
                    messageContent: text, // Pass message content
                    messageType: 'text', // Explicitly set message type
                  );
                  _scrollToBottom(); // Scroll after sending a message
                },
                onAttachmentPressed: _pickImage, // Pass the image picker method
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose the controller
    Provider.of<ChatProvider>(context, listen: false).removeListener(_onChatProviderChange);
    super.dispose();
  }
}
