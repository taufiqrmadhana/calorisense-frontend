import 'package:calorisense/core/common/widgets/bottom_navbar.dart';
import 'package:calorisense/core/theme/pallete.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  static route() => MaterialPageRoute(builder: (context) => ProfilePage());
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppPalette.white,
        elevation: 0,
        title: GestureDetector(
          // onTap: () {
          //   Navigator.pushReplacement(context, HomePage.route());
          // },
          child: Image.asset('assets/images/image.png', height: 150),
        ),

        shape: const Border(
          bottom: BorderSide(width: 1, color: AppPalette.borderColor),
        ),
      ),
      body: const Center(
        child: Text(
          'This is the Chat Page',
          style: TextStyle(color: AppPalette.textColor),
        ),
      ),
      bottomNavigationBar: BottomNavBarWidget(currentIndex: 2),
    );
  }
}
