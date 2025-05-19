import 'package:calorisense/core/common/widgets/bottom_navbar.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  static route() => MaterialPageRoute(builder: (context) => ProfilePage());
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(child: Text('This is the Chat Page')),
      bottomNavigationBar: BottomNavBarWidget(currentIndex: 3),
    );
  }
}
