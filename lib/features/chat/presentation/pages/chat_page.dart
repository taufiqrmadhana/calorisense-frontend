import 'package:calorisense/core/common/widgets/bottom_navbar.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  static route() => MaterialPageRoute(builder: (context) => ChatPage());
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: const Center(child: Text('This is the Chat Page')),
      bottomNavigationBar: BottomNavBarWidget(currentIndex: 1),
    );
  }
}
