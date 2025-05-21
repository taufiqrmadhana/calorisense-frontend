import 'dart:convert';
import 'dart:async';
import 'package:calorisense/core/common/widgets/bottom_navbar.dart';
import 'package:calorisense/core/theme/pallete.dart';
import 'package:calorisense/features/chat/presentation/widgets/user_bubble.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../widgets/bot_bubble.dart';

class ChatPage extends StatefulWidget {
  static route() => MaterialPageRoute(builder: (context) => const ChatPage());
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Map<String, String>> messages = [
    {
      'sender': 'bot',
      'text': 'Hi! How can I help you track your health today? 😊',
    },
  ];

  final TextEditingController _controller = TextEditingController();
  WebSocketChannel? _channel;
  bool _isProcessing = false;
  String _partialResponse = '';
  bool _isStreaming = false;
  final String _userEmail = "taufiqaja@gmail.com"; // Hardcoded for now
  final ScrollController _scrollController = ScrollController();
  StreamSubscription? _socketSubscription;

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
  }

  @override
  void dispose() {
    _socketSubscription?.cancel(); // Cancel the subscription
    _channel?.sink.close();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _connectWebSocket() async {
    try {
      final wsUrl = Uri.parse('ws://localhost:8000/chat/ws/$_userEmail');
      _channel = WebSocketChannel.connect(wsUrl);
      
       _socketSubscription =_channel!.stream.listen((message) {
        final data = jsonDecode(message);
        
        if (data['status'] == 'processing') {
          setState(() {
            _isProcessing = true;
          });
        } 
        // Handle streaming start
        else if (data['status'] == 'streaming_start') {
          setState(() {
            _isStreaming = true;
            _partialResponse = '';
            // Add an empty bot message that will be filled with streaming tokens
            messages.add({
              'sender': 'bot',
              'text': '',
              'streaming': 'true',
            });
          });
          // Scroll to the bottom to show the streaming message
          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
        }
        // Handle streaming tokens
        else if (data['status'] == 'streaming_token') {
          setState(() {
            _partialResponse += data['token'];
            // Update the last message with the current partial response
            final lastIndex = messages.length - 1;
            if (lastIndex >= 0 && messages[lastIndex]['streaming'] == 'true') {
              messages[lastIndex]['text'] = _partialResponse;
            }
          });
          // Scroll to the bottom as tokens come in
          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
        }
        // Handle streaming end
        else if (data['status'] == 'streaming_end') {
          setState(() {
            _isProcessing = false;
            _isStreaming = false;
            // Update the last message with final response
            final lastIndex = messages.length - 1;
            if (lastIndex >= 0 && messages[lastIndex]['streaming'] == 'true') {
              messages[lastIndex]['text'] = data['response'];
              messages[lastIndex].remove('streaming');
            }
          });
          
          // If info was updated, show a snackbar
          if (data['info_updated'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Your ${data["intent"] ?? "information"} has been updated!'),
                backgroundColor: AppPalette.primaryColor,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
        // Handle completed message (non-streaming)
        else if (data['status'] == 'completed' || data.containsKey('response')) {
          setState(() {
            _isProcessing = false;
            messages.add({
              'sender': 'bot',
              'text': data['response'],
            });
          });
          
          // If info was updated, show a snackbar
          if (data['info_updated'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Your ${data["intent"] ?? "information"} has been updated!'),
                backgroundColor: AppPalette.primaryColor,
                duration: const Duration(seconds: 2),
              ),
            );
          }
          
          // Scroll to the bottom to show the new message
          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
        } 
        else if (data['status'] == 'error') {
          setState(() {
            _isProcessing = false;
            _isStreaming = false;
            messages.add({
              'sender': 'bot',
              'text': 'Sorry, there was an error processing your request. Please try again.',
            });
          });
          // Scroll to the bottom to show the error message
          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
        }
      }, onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connection error. Please check your internet connection.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isProcessing = false;
          _isStreaming = false;
        });
      }, onDone: () {
        // Attempt to reconnect if connection is lost
        Future.delayed(const Duration(seconds: 2), _connectWebSocket);
      });
    } catch (e) {
      print('WebSocket connection error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('WebSocket connection error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    if (_channel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not connected to server. Reconnecting...'),
          backgroundColor: Colors.orange,
        ),
      );
      _connectWebSocket();
      return;
    }
    
    final messageText = _controller.text.trim();
    
    setState(() {
      messages.add({'sender': 'user', 'text': messageText});
      _controller.clear();
    });
    
    // Send message to WebSocket server
    _channel!.sink.add(jsonEncode({
      'message': messageText,
    }));
    
    // Scroll to the bottom to show the user message
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppPalette.white,
        elevation: 0,
        title: Image.asset('assets/images/image.png', height: 150),
        shape: const Border(
          bottom: BorderSide(width: 1, color: AppPalette.borderColor),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: ListView.separated(
                controller: _scrollController,
                itemCount: messages.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  return msg['sender'] == 'bot'
                      ? BotBubble(
                          message: msg['text']!,
                          isTyping: msg.containsKey('streaming') && _isStreaming,
                        )
                      : UserBubble(message: msg['text']!);
                },
              ),
            ),
          ),
          // Show typing indicator only when processing but not streaming
          if (_isProcessing && !_isStreaming)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: BotBubble(message: 'Thinking...', isTyping: true),
              ),
            ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: AppPalette.white,
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: AppPalette.textColor),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(
                          color: AppPalette.darkSubTextColor,
                        ),
                        filled: true,
                        fillColor: AppPalette.lightGrey,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _isProcessing ? null : _sendMessage(),
                      enabled: !_isProcessing, // Disable input while processing
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _isProcessing ? null : _sendMessage,
                    child: CircleAvatar(
                      backgroundColor: _isProcessing 
                          ? AppPalette.lightGrey 
                          : AppPalette.primaryColor,
                      child: Icon(
                        Icons.send, 
                        color: _isProcessing ? AppPalette.darkSubTextColor : Colors.white, 
                        size: 20
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBarWidget(currentIndex: 1),
    );
  }
}