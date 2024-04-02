// ignore_for_file: prefer_const_constructors, must_be_immutable, prefer_const_literals_to_create_immutables, unused_import, unused_local_variable

import '../utils/dbHelper.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../models/chatUsers.dart';
import '../models/chatMessages.dart';
import '../widgets/conversationList.dart';
import 'package:word_generator/word_generator.dart';
import '../views/chatDetailsPage.dart';

class HomeScreen extends StatefulWidget {
  int userId;
  HomeScreen(this.userId, {super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int itemCount = 0;
  late Future<List<Map<String, dynamic>>> userData;
  

  @override
  void initState() {
    super.initState();
    userData = _fetchUserData();
  }

Future<List<Map<String, dynamic>>> _fetchUserData() async {
  List<Map<String, dynamic>> data = await ChatMessages().getLastMessages(widget.userId);
  return data;
}

  void _openNewChatPopup(BuildContext context) {
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
        String? username = items.first;
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
                String generateRandomContactNumber() {
                  Random random = Random();
                  String contactNumber = '';
                  for (int i = 0; i < 10; i++) {
                    contactNumber += random.nextInt(10).toString();
                  }
                  return contactNumber;
                }
                Random random = Random();
                int randomInt = random.nextInt(100);
                final newUser = ChatUsers(
                  userId: randomInt,
                  username: username,
                  contact: generateRandomContactNumber(),
                );

                await newUser.dbSave();

                final chatMessages = ChatMessages(
                  senderId: widget.userId,
                  receiverId: randomInt,
                  messageContent: '',
                  timeStamp: DateTime.now(),
                );

                await chatMessages.dbSave();
                Navigator.pop(context);

                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (_) => ChatDetailsPage(widget.userId, randomInt, username as String),
                ));
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
    return FutureBuilder<List<Map<String, dynamic>>>(
        future: userData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else {
            final data = snapshot.data as List<Map<String, dynamic>>;
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
                            onTap: () => _openNewChatPopup(context),
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
                    itemCount: data.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final message = data[index];
                      return ConversationList(
                        userId: widget.userId,
                        receiverId: message['receiverId'],
                        name: message['username'] ?? "",
                        messageContent: message['messageContent'] ?? "",
                        timeStamp: DateTime.parse(message['timeStamp'])
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