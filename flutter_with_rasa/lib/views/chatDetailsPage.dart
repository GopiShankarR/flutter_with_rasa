// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chatDetailsNotifier.dart';

class ChatDetailsPage extends StatelessWidget {
  final int userId;
  final int receiverId;
  final String username;

  ChatDetailsPage(this.userId, this.receiverId, this.username, {super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatDetailsNotifier(userId, receiverId),
      child: _ChatDetailsPage(username),
    );
  }
}

class _ChatDetailsPage extends StatefulWidget {
  final String username;

  const _ChatDetailsPage(this.username);

  @override
  __ChatDetailsPageState createState() => __ChatDetailsPageState();
}

class __ChatDetailsPageState extends State<_ChatDetailsPage> {
  late TextEditingController _messageController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _fetchInitialChatData();
  }

  Future<void> _fetchInitialChatData() async {
    await Provider.of<ChatDetailsNotifier>(context, listen: false).fetchChats();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.username),
        backgroundColor: Colors.purple[200],
      ),
      body: Stack(
        children: <Widget>[
          if (_isLoading)
            Center(child: CircularProgressIndicator()),
          if (!_isLoading)
            Column(
              children: [
                Expanded(
                  child: Consumer<ChatDetailsNotifier>(
                    builder: (context, notifier, _) {
                      return ListView.builder(
                        itemCount: notifier.chats.length,
                        itemBuilder: (context, index) {
                          final chat = notifier.chats[index];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: chat.messages.length,
                                itemBuilder: (context, messageIndex) {
                                  final message = chat.messages[messageIndex];
                                  bool isSender = message.senderId == notifier.userId;
                                  return Container(
                                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                    alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
                                    child: Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: message.messageContent != '' ? BoxDecoration(
                                        color: isSender ? Colors.blue[200] : Colors.grey[200],
                                        borderRadius: BorderRadius.circular(15),
                                      ) : null,
                                      child: Text(
                                        message.messageContent!,
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    padding: EdgeInsets.only(left: 10),
                    height: 60,
                    width: double.infinity,
                    color: Colors.white,
                    child: Row(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                              color: Colors.purple[200],
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Icon(Icons.add, color: Colors.white, size: 20),
                          ),
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: "Write message...",
                              hintStyle: TextStyle(color: Colors.black54),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        SizedBox(width: 15),
                        FloatingActionButton(
                          onPressed: () {
                            Provider.of<ChatDetailsNotifier>(context, listen: false).sendMessage(_messageController.text);
                            _messageController.clear();
                          },
                          child: Icon(Icons.send, color: Colors.white, size: 18),
                          backgroundColor: Colors.purple[200],
                          elevation: 0,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
        ]
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
