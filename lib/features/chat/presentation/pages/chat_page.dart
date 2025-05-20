import 'dart:convert';
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
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
  }

  @override
  void dispose() {
    _channel?.sink.close();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _connectWebSocket() async {
    // TODO: Replace with your actual user email retrieval logic
    _userEmail = "taufiqaja@gmail.com"; // Replace with actual user email from auth
    
    try {
      final wsUrl = Uri.parse('ws://localhost:8000/chat/ws/$_userEmail');
      _channel = WebSocketChannel.connect(wsUrl);
      
      _channel!.stream.listen((message) {
        final data = jsonDecode(message);
        
        if (data['status'] == 'processing') {
          setState(() {
            _isProcessing = true;
          });
        } else if (data['status'] == 'completed' || data.containsKey('response')) {
          setState(() {
            _isProcessing = false;
            messages.add({
              'sender': 'bot',
              'text': data['response'],
            });
          });
          
          // If info was updated, you can add special handling here
          if (data['info_updated'] == true) {
            // Optional: Show a snackbar or some visual indication
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Your ${data["intent"] ?? "information"} has been updated!'),
                backgroundColor: AppPalette.primaryColor,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } else if (data['status'] == 'error') {
          setState(() {
            _isProcessing = false;
            messages.add({
              'sender': 'bot',
              'text': 'Sorry, there was an error processing your request. Please try again.',
            });
          });
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
        });
      }, onDone: () {
        // Attempt to reconnect if connection is lost
        Future.delayed(const Duration(seconds: 2), _connectWebSocket);
      });
    } catch (e) {
      print('WebSocket connection error: $e');
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
    
    // Show typing indicator
    setState(() {
      _isProcessing = true;
    });
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
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            child: ListView.separated(
              itemCount: messages.length + (_isProcessing ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == messages.length && _isProcessing) {
                  // Show typing indicator
                  return BotBubble(message: 'Thinking...', isTyping: true);
                }
                
                final msg = messages[index];
                return msg['sender'] == 'bot'
                    ? BotBubble(message: msg['text']!)
                    : UserBubble(message: msg['text']!);
              },
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
                      onSubmitted: (_) => _sendMessage(),
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