import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/chat_service.dart';

class ChatMessage {
  final String content;
  final bool isUser;
  
  ChatMessage({required this.content, required this.isUser});
}

class ChatScreen extends ConsumerStatefulWidget {
  final String? pdfId;
  final String pdfTitle;

  const ChatScreen({
    super.key, 
    this.pdfId, 
    this.pdfTitle = 'AI Tutor',
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _chatId;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      final id = await ref.read(chatServiceProvider).createChat('Chat regarding ${widget.pdfTitle}');
      if (!mounted) return;
      setState(() {
        _chatId = id;
        _messages.add(ChatMessage(
          content: 'Hello! I am your AI Tutor. I have access to "${widget.pdfTitle}". How can I help you study today?',
          isUser: false,
        ));
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _chatId == null) return;

    final userText = _messageController.text.trim();
    _messageController.clear();

    setState(() {
      _messages.add(ChatMessage(content: userText, isUser: true));
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final aiResponse = await ref.read(chatServiceProvider).sendMessage(
        _chatId!, 
        userText, 
        pdfId: widget.pdfId,
      );

      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(content: aiResponse['content'], isUser: false));
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(content: 'Error: Could not reach the AI server.', isUser: false));
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.auto_awesome, color: Colors.cyan).animate().shimmer(duration: 2.seconds, delay: 1.seconds),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.pdfTitle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(msg, index);
              },
            ),
          ),
          if (_isLoading)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('AI is thinking', style: TextStyle(color: Colors.cyan)),
                  const SizedBox(width: 8),
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.cyan),
                  ).animate(onPlay: (controller) => controller.repeat()).rotate(),
                ],
              ),
            ).animate().fadeIn(),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, int index) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: message.isUser 
                ? [Theme.of(context).colorScheme.primary, Colors.deepPurpleAccent]
                : [Theme.of(context).colorScheme.surfaceVariant, Colors.grey.shade900],
          ),
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomRight: message.isUser ? const Radius.circular(0) : const Radius.circular(20),
            bottomLeft: !message.isUser ? const Radius.circular(0) : const Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: message.isUser ? Theme.of(context).colorScheme.primary.withOpacity(0.3) : Colors.black12,
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        child: Text(
          message.content,
          style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: message.isUser ? 0.2 : -0.2, end: 0);
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Message AI Tutor...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Theme.of(context).colorScheme.secondary.withOpacity(0.4), blurRadius: 12)
                  ],
                ),
                child: const Icon(Icons.send, color: Colors.black),
              ),
            ).animate(target: _messageController.text.isNotEmpty ? 1 : 0).scale(),
          ],
        ),
      ),
    );
  }
}
