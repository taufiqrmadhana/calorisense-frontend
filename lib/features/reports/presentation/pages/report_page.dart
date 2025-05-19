import 'package:calorisense/core/common/widgets/bottom_navbar.dart';
import 'package:flutter/material.dart';

class ReportPage extends StatelessWidget {
  static route() => MaterialPageRoute(builder: (context) => ReportPage());
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: const Center(child: Text('This is the Chat Page')),
      bottomNavigationBar: BottomNavBarWidget(currentIndex: 2),
    );
  }
}
