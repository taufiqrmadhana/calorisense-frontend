import 'package:calorisense/core/common/widgets/bottom_navbar.dart';
import 'package:calorisense/core/theme/pallete.dart';
import 'package:calorisense/features/chat/presentation/widgets/user_bubble.dart';
import 'package:flutter/material.dart';
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
      'text': 'Hi Madgun! How can I help you track your health today? 😊',
    },
  ];

  final TextEditingController _controller = TextEditingController();

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      messages.add({'sender': 'user', 'text': _controller.text.trim()});
      _controller.clear();
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
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: Colors.black54,
            ),
            onPressed: () {},
          ),
          const CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
        ],
        shape: const Border(
          bottom: BorderSide(width: 1, color: AppPalette.borderColor),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            child: ListView.separated(
              itemCount: messages.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
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
                        fillColor: const Color(0xFFF5F5F5),
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
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: const CircleAvatar(
                      backgroundColor: AppPalette.primaryColor,
                      child: Icon(Icons.send, color: Colors.white),
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
