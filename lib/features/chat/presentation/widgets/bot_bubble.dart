import 'package:calorisense/core/theme/pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class BotBubble extends StatelessWidget {
  final String message;
  final bool isTyping;

  const BotBubble({
    Key? key,
    required this.message,
    this.isTyping = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundColor: AppPalette.primaryColor,
          radius: 18,
          child: Image.asset(
            'assets/images/bot_avatar.png',
            height: 24,
            width: 24,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppPalette.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppPalette.borderColor, width: 1),
            ),
            child: isTyping
                ? _buildTypingIndicator()
                : MarkdownBody(
                    data: message,
                    styleSheet: MarkdownStyleSheet(
                      p: const TextStyle(
                        color: AppPalette.textColor,
                        fontSize: 16,
                      ),
                      strong: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppPalette.textColor,
                      ),
                      em: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: AppPalette.textColor,
                      ),
                      code: TextStyle(
                        fontFamily: 'monospace',
                        backgroundColor: AppPalette.lightGrey,
                        color: AppPalette.textColor,
                      ),
                      codeblockDecoration: BoxDecoration(
                        color: AppPalette.lightGrey,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypingIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildDot(0),
        _buildDot(1),
        _buildDot(2),
      ],
    );
  }

  Widget _buildDot(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: TweenAnimationBuilder(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 600),
        curve: Interval(
          index * 0.2, // Stagger the animations
          index * 0.2 + 0.6,
          curve: Curves.easeInOut,
        ),
        builder: (context, double value, child) {
          return Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppPalette.primaryColor.withOpacity(0.3 + value * 0.7),
              shape: BoxShape.circle,
            ),
          );
        },
      ),
    );
  }
}