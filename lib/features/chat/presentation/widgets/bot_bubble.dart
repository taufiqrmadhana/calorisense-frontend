import 'package:calorisense/core/theme/pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class BotBubble extends StatefulWidget {
  final String message;
  final bool isTyping;

  const BotBubble({
    Key? key,
    required this.message,
    this.isTyping = false,
  }) : super(key: key);

  @override
  State<BotBubble> createState() => _BotBubbleState();
}

class _BotBubbleState extends State<BotBubble> {
  bool _showTypingIndicator = false;
  
  @override
  void initState() {
    super.initState();
    _updateTypingState();
  }
  
  @override
  void didUpdateWidget(BotBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Handle changes in typing state or message content
    if (oldWidget.isTyping != widget.isTyping || 
        oldWidget.message != widget.message) {
      _updateTypingState();
    }
  }
  
  void _updateTypingState() {
    // Only show typing indicator when actively streaming
    // and not just showing the initial "Thinking..." message
    setState(() {
      _showTypingIndicator = widget.isTyping && 
                            (widget.message != 'Thinking...' && widget.message.isNotEmpty);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // Prevent horizontal overflow
      children: [
        CircleAvatar(
          backgroundColor: AppPalette.primaryColor,
          radius: 18,
          child: const Icon(
            Icons.smart_toy_outlined,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 8),
        Expanded( // Use Expanded instead of Flexible to properly constrain width
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppPalette.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppPalette.borderColor, width: 1),
            ),
            child: widget.message == 'Thinking...'
                ? _buildTypingIndicator()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min, // Prevent vertical overflow
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.7,
                          ),
                          child: MarkdownBody(
                            data: widget.message,
                            softLineBreak: true,
                            shrinkWrap: true,
                            styleSheet: MarkdownStyleSheet(
                              p: const TextStyle(
                                color: AppPalette.textColor,
                                fontSize: 16,
                                height: 1.4,
                              ),
                              strong: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppPalette.textColor,
                              ),
                              em: const TextStyle(
                                fontStyle: FontStyle.italic,
                                color: AppPalette.textColor,
                              ),
                              code: const TextStyle(
                                fontFamily: 'monospace',
                                backgroundColor: AppPalette.lightGrey,
                                color: AppPalette.textColor,
                              ),
                              codeblockPadding: const EdgeInsets.all(8),
                              codeblockDecoration: BoxDecoration(
                                color: AppPalette.lightGrey,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              a: const TextStyle(
                                color: AppPalette.primaryColor, 
                                decoration: TextDecoration.underline,
                              ),
                              blockquote: const TextStyle(
                                color: AppPalette.textColor,
                                fontStyle: FontStyle.italic,
                              ),
                              tableBody: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Add typing indicator at the end of the message when streaming
                      if (_showTypingIndicator)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: _buildTypingIndicator(),
                        ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDot(0),
        _buildDot(1),
        _buildDot(2),
      ],
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut, // Smoother animation
      builder: (context, value, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppPalette.primaryColor.withOpacity(0.3 + (value * 0.7 + index * 0.1) % 0.7),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}