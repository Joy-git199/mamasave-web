import 'package:flutter/material.dart';

class MessagingPage extends StatefulWidget {
  const MessagingPage({super.key});

  @override
  State<MessagingPage> createState() => _MessagingPageState();
}

class _MessagingPageState extends State<MessagingPage> {
  final List<Map<String, String>> messages = [
    {"sender": "Midwife", "text": "How are you feeling today?"},
    {"sender": "Mother", "text": "I’ve been having back pain."},
  ];

  final TextEditingController messageController = TextEditingController();

  void sendMessage() {
    final text = messageController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        messages.add({"sender": "Midwife", "text": text});
        messageController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMidwife = msg["sender"] == "Midwife";
                return Align(
                  alignment:
                      isMidwife ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isMidwife ? Colors.blue[100] : Colors.green[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(msg["text"]!),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration:
                        const InputDecoration(hintText: 'Type a message...'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: sendMessage,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
