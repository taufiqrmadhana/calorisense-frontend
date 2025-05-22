import 'dart:convert';
import 'dart:async';
import 'package:calorisense/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:calorisense/core/common/widgets/bottom_navbar.dart';
import 'package:calorisense/core/theme/pallete.dart';
import 'package:calorisense/features/chat/presentation/widgets/user_bubble.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../widgets/bot_bubble.dart';
import 'package:calorisense/core/common/entities/user.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  String? _currentUserEmail; // Hardcoded for now
  final ScrollController _scrollController = ScrollController();
  StreamSubscription? _socketSubscription;

  @override
  void initState() {
    super.initState();
    // Ambil email pengguna dari AppUserCubit
    // Sebaiknya gunakan addPostFrameCallback untuk memastikan context siap
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Selalu cek mounted
        final appUserState = context.read<AppUserCubit>().state;
        if (appUserState is AppUserLoggedIn) {
          _currentUserEmail = appUserState.user.email;
          if (_currentUserEmail != null && _currentUserEmail!.isNotEmpty) {
            _connectWebSocket(
              _currentUserEmail!,
            ); // Panggil dengan email yang sudah didapat
          } else {
            _showChatError(
              "User email is not available. Cannot connect to chat.",
            );
          }
        } else {
          _showChatError("User not logged in. Cannot connect to chat.");
        }
      }
    });
  }

  void _showChatError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
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

  Future<void> _connectWebSocket(String userEmail) async {
    if (userEmail.isEmpty) {
      print("DEBUG: ChatPage - Cannot connect WebSocket, userEmail is empty.");
      _showChatError("User email is required to connect to chat.");
      return;
    }

    // Tutup channel lama jika ada sebelum membuat yang baru
    if (_channel != null) {
      _socketSubscription?.cancel();
      _channel!.sink.close();
      _channel = null;
      print(
        "DEBUG: ChatPage - Previous WebSocket channel closed for reconnection.",
      );
    }

    try {
      // Gunakan userEmail dari parameter
      final wsUrl = Uri.parse(
        'wss://calorisense.onrender.com/chat/ws/$userEmail', // Pastikan path ini benar
      );
      print("DEBUG: ChatPage - Connecting to WebSocket: $wsUrl");
      _channel = WebSocketChannel.connect(wsUrl);

      _socketSubscription = _channel!.stream.listen(
        (message) {
          final data = jsonDecode(message);
          // ... (sisa logika penanganan pesan Anda, sudah terlihat baik)
          // Pastikan semua setState aman dengan mengecek `mounted` jika perlu,
          // meskipun di dalam stream listen biasanya aman jika subscription dibatalkan di dispose.

          if (data['status'] == 'processing') {
            if (mounted) setState(() => _isProcessing = true);
          } else if (data['status'] == 'streaming_start') {
            if (mounted) {
              setState(() {
                _isStreaming = true;
                _partialResponse = '';
                messages.add({
                  'sender': 'bot',
                  'text': '',
                  'streaming': 'true',
                });
              });
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => _scrollToBottom(),
              );
            }
          } else if (data['status'] == 'streaming_token') {
            if (mounted) {
              setState(() {
                _partialResponse += data['token'];
                final lastIndex = messages.length - 1;
                if (lastIndex >= 0 &&
                    messages[lastIndex]['streaming'] == 'true') {
                  messages[lastIndex]['text'] = _partialResponse;
                }
              });
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => _scrollToBottom(),
              );
            }
          } else if (data['status'] == 'streaming_end') {
            if (mounted) {
              setState(() {
                _isProcessing = false;
                _isStreaming = false;
                final lastIndex = messages.length - 1;
                if (lastIndex >= 0 &&
                    messages[lastIndex]['streaming'] == 'true') {
                  messages[lastIndex]['text'] = data['response'];
                  messages[lastIndex].remove('streaming');
                }
              });
              if (data['info_updated'] == true && mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Data Updated!")));
              }
            }
          } else if (data['status'] == 'completed' ||
              data.containsKey('response')) {
            if (mounted) {
              setState(() {
                _isProcessing = false;
                messages.add({'sender': 'bot', 'text': data['response']});
              });
              if (data['info_updated'] == true && mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Data Updated!")));
              }
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => _scrollToBottom(),
              );
            }
          } else if (data['status'] == 'error') {
            if (mounted) {
              setState(() {
                _isProcessing = false;
                _isStreaming = false;
                messages.add({
                  'sender': 'bot',
                  'text':
                      'Sorry, there was an error processing your request. Please try again.',
                });
              });
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => _scrollToBottom(),
              );
            }
          }
        },
        onError: (error) {
          print("DEBUG: ChatPage - WebSocket onError: $error");
          if (mounted) {
            _showChatError('Chat connection error. Trying to reconnect...');
            setState(() {
              _isProcessing = false;
              _isStreaming = false;
            });
            // Coba sambungkan kembali setelah jeda, gunakan userEmail parameter
            Future.delayed(const Duration(seconds: 5), () {
              if (mounted && userEmail.isNotEmpty) _connectWebSocket(userEmail);
            });
          }
        },
        onDone: () {
          print("DEBUG: ChatPage - WebSocket onDone (connection closed).");
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Chat disconnected. Attempting to reconnect...'),
                backgroundColor: Colors.orange,
              ),
            );
            setState(() {
              _isProcessing = false;
              _isStreaming = false;
            });
            // Coba sambungkan kembali setelah jeda, gunakan userEmail parameter
            Future.delayed(const Duration(seconds: 5), () {
              if (mounted && userEmail.isNotEmpty) _connectWebSocket(userEmail);
            });
          }
        },
        cancelOnError:
            true, // Baik untuk menghentikan jika ada error yang tidak bisa pulih
      );
      print("DEBUG: ChatPage - WebSocket stream listening.");
    } catch (e) {
      print('DEBUG: ChatPage - WebSocket connection error in try-catch: $e');
      if (mounted) {
        _showChatError('WebSocket connection failed: $e');
        setState(() {
          // Pastikan state direset jika koneksi awal gagal
          _isProcessing = false;
          _isStreaming = false;
        });
      }
    }
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    if (_channel == null) {
      // Periksa juga sink
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not connected to server. Reconnecting...'),
          backgroundColor: Colors.orange,
        ),
      );
      // Coba sambungkan kembali dengan email yang sudah tersimpan (_currentUserEmail)
      if (_currentUserEmail != null && _currentUserEmail!.isNotEmpty) {
        _connectWebSocket(_currentUserEmail!);
      } else {
        _showChatError(
          "Cannot send message: User email not available for reconnection.",
        );
      }
      return;
    }

    final messageText = _controller.text.trim();

    if (mounted) {
      setState(() {
        messages.add({'sender': 'user', 'text': messageText});
        _controller.clear();
        // Langsung scroll setelah user mengirim pesan
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      });
    }

    _channel!.sink.add(jsonEncode({'message': messageText}));

    // Tidak perlu scroll lagi di sini karena sudah dilakukan saat user message ditambahkan
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
                      backgroundColor:
                          _isProcessing
                              ? AppPalette.lightGrey
                              : AppPalette.primaryColor,
                      child: Icon(
                        Icons.send,
                        color:
                            _isProcessing
                                ? AppPalette.darkSubTextColor
                                : Colors.white,
                        size: 20,
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
