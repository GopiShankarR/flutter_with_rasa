// ignore_for_file: prefer_const_constructors, must_be_immutable, prefer_const_literals_to_create_immutables, unused_import, unused_local_variable

import 'package:flutter_with_rasa/views/loginPage.dart';

import '../utils/dbHelper.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../models/socketProvider.dart';
import '../widgets/conversationList.dart';
import 'package:word_generator/word_generator.dart';
import '../views/chatDetailsPage.dart';
import 'dart:async';

class Conversation {
  final double conversationId;
  final List<double> participantIds;
  final String? lastMessage;
  final String username;
  final DateTime? lastMessageTime;

  Conversation({
    required this.conversationId,
    required this.participantIds,
    required this.username,
    this.lastMessage,
    this.lastMessageTime,
  });

  factory Conversation.fromMap(Map<String, dynamic> map) => Conversation(
    conversationId: map['conversationId'],
    participantIds: (map['participantIds']as List).cast<double>(),
    lastMessage: map['lastMessage'],
    username: map['username'],
    lastMessageTime: map['lastMessageTime'] != null
        ? DateTime.parse(map['lastMessageTime'])
        : null,
  );
}

class HomeScreen extends StatefulWidget {
  double userId;
  final SocketProvider? _socket;
  HomeScreen(this.userId, this._socket, {super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int itemCount = 0;
  double receiverId = 0;
  late Future<List<Conversation>> _conversations;
  
  @override
  void initState() {
    super.initState();
    _conversations = _fetchConversations();
  }

  Future<List<Conversation>> _fetchConversations() async {
    Completer<List<Conversation>> completer = Completer<List<Conversation>>();
    widget._socket?.socket?.emit('get_logged_in_users', widget.userId);

    widget._socket?.socket?.on('logged_in_users', (data) {
      List<Conversation> conversations = (data as List)
          .map((user) => Conversation.fromMap(user))
          .toList();

      completer.complete(conversations);
    });
    List<Conversation> conversations = await completer.future;
    return conversations;
  }

  void _openNewChatPopup(BuildContext context, SocketProvider? _socket) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        List<String> names = [];
        List<String> randomNames() {
          for (int i = 0; i < 5; i++) {
            names.add(WordGenerator().randomName());
          }
          return names;
        }
        List<String> items = randomNames();
        String username = items.first;
        return AlertDialog(
          title: Text('Search'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  value: username,
                  items: items.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      username = newValue!;
                    });
                  },
                ),
              ]
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Close'),
            ),
            SizedBox(width: 30),
            TextButton(
              onPressed: () async {
                String contactNumber = '';
                String generateRandomContactNumber() {
                  Random random = Random();
                  for (int i = 0; i < 10; i++) {
                    contactNumber += random.nextInt(10).toString();
                  }
                  return contactNumber;
                }
                Random random = Random();
                int randomInt = random.nextInt(100);
                final newUser = {'username': username, 'password': '', 'contact': contactNumber};
                _socket?.socket?.emit('create_new_user', newUser);
                _socket?.socket?.on('create_new_user_response', (response) {
                  receiverId = response;
                  if(response.runtimeType == double) {
                    final mapIds = {'userId': widget.userId, 'receiverId': receiverId};
                    _socket.socket?.emit('map_conversation', mapIds);
                    _socket.socket?.on('conversation_id', (response) {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (_) => ChatDetailsPage(widget._socket, widget.userId.toDouble(), receiverId, username, response),
                      ));
                    });
                  }
                });
              },
              child: Text('Chat'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Conversation>>(
        future: _conversations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else {
            final conversation = snapshot.data as List<Conversation>;
            return Scaffold(
            body: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SafeArea(
                    child: Padding(
                      padding: EdgeInsets.only(left: 16,right: 16,top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget> [
                          Text("Conversations", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),),
                          GestureDetector(
                            onTap: () => _openNewChatPopup(context, widget._socket),
                            child: Container(
                              padding: EdgeInsets.only(left: 8, right: 8,top: 2, bottom: 2),
                              height: 30,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Colors.purple[50],
                              ),
                              child: Row(
                                children: <Widget>[
                                  Icon(Icons.add,color: Color.fromRGBO(90, 23, 238, 0.4), size: 20,),
                                  SizedBox(width: 2,),
                                  Text("New Chat", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                '/',
                                (Route<dynamic> route) => false,
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.only(left: 8, right: 8,top: 2, bottom: 2),
                              height: 30,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Colors.purple[50],
                              ),
                              child: Row(
                                children: <Widget>[
                                  Icon(Icons.logout, color: Color.fromRGBO(90, 23, 238, 0.4), size: 20,),
                                  SizedBox(width: 1,),
                                  Text("Logout", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16,left: 16,right: 16),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search...",
                        hintStyle: TextStyle(color: Colors.grey.shade600),
                        prefixIcon: Icon(Icons.search,color: Colors.grey.shade600, size: 20,),
                        filled: true,
                        fillColor: Colors.purple.shade50,
                        contentPadding: EdgeInsets.all(8),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                                color: Colors.grey.shade100
                            )
                        ),
                      ),
                    ),
                  ),
                  ListView.builder(
                    itemCount: conversation.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final message = conversation[index];
                      return ConversationList(
                        widget._socket,
                        userId: widget.userId,
                        receiverId: message.participantIds[1],
                        messageContent: message.lastMessage,
                        conversationId: message.conversationId,
                        name: message.username == "" ? "" : message.username,
                        timeStamp: message.lastMessageTime
                      );
                    },
                  ),
                ],
                
              ),
            ),
          );
        }
      }
    );
  }
}