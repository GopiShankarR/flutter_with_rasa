// ignore_for_file: prefer_const_constructors, must_be_immutable, unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:flutter_with_rasa/models/chatMessages.dart';
import '../views/chatDetailsPage.dart';

class ConversationList extends StatefulWidget {
  int userId;
  int receiverId;
  String name;
  String messageContent;
  DateTime timeStamp;
  ConversationList({super.key, required this.userId, required this.receiverId, required this.messageContent, required this.name, required this.timeStamp});

  @override
  State<ConversationList> createState() => _ConversationListState();
}

class _ConversationListState extends State<ConversationList> {
  late Future<List<ChatMessages>> conversations;

  @override
  void initState() {
    super.initState();
    conversations = _fetchMessagesData();
  }

  Future<List<ChatMessages>> _fetchMessagesData() async {
    List<ChatMessages> data = await ChatMessages().queryData(widget.userId);
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          if(widget.messageContent != "")
            Text(
              ChatMessages().processTimestamp(widget.timeStamp), // Format time as 'H:mm' (24-hour format)
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12.0,
              ),
            ),
        ],
      ),
      subtitle: Container(
        padding: EdgeInsets.only(top: 5.0),
        child: Text(
          widget.messageContent,
          style: TextStyle(
            color: Colors.grey,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      onTap: () {
        Navigator.push(
          context, MaterialPageRoute(
            builder: (context) {
              return ChatDetailsPage(widget.userId, widget.receiverId, widget.name);
            }
          )
        );
      },
    );
    // GestureDetector(
    //   onTap: () {
    //     Navigator.push(
    //       context, MaterialPageRoute(
    //         builder: (context) {
    //           return ChatDetailsPage(widget.userId, widget.name);
    //         }
    //       )
    //     );
    //   },
    //   child: Container(
    //     padding: EdgeInsets.only(left: 16,right: 16,top: 10,bottom: 10),
    //     child: Row(
    //       children: <Widget>[
    //         Expanded(
    //           child: Row(
    //             children: <Widget>[
    //               SizedBox(width: 16,),
    //               Expanded(
    //                 child: Container(
    //                   color: Colors.transparent,
    //                   child: Column(
    //                     crossAxisAlignment: CrossAxisAlignment.start,
    //                     children: <Widget>[
    //                       Text(widget.name, style: TextStyle(fontSize: 16),),
    //                       SizedBox(height: 6,),
    //                       Text(widget.messageContent),
    //                     ],
    //                   ),
    //                 ),
    //               ),
    //             ],
    //           ),
    //         ),
    //         Text("${ChatMessages().processTimestamp(widget.timeStamp)}"),
    //       ],
    //     ),
    //   ),
    // );
  //   FutureBuilder<List<ChatMessages>>(
  //       future: conversations,
  //       builder: (context, snapshot) {
  //         if (snapshot.connectionState == ConnectionState.waiting) {
  //           return const Scaffold(
  //             body: Center(
  //               child: CircularProgressIndicator(),
  //             ),
  //           );
  //         } else {
  //           final data = snapshot.data as List<ChatMessages>;
  //           return Scaffold(body: 
  //           GestureDetector(
  //             onTap: () {
  //               Navigator.push(
  //                 context, MaterialPageRoute(
  //                   builder: (context) {
  //                     return ChatDetailsPage(widget.userId, widget.name);
  //                   }
  //                 )
  //               );
  //             },
  //             child: ListView.builder(
  //               itemCount: data.length,
  //               itemBuilder: (context, index) {
  //                 return Container(
  //                   padding: EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
  //                   child: Row(
  //                     children: <Widget>[
  //                       Expanded(
  //                         child: Row(
  //                           children: <Widget>[
  //                             SizedBox(width: 16,),
  //                             Expanded(
  //                               child: Container(
  //                                 color: Colors.transparent,
  //                                 child: Column(
  //                                   crossAxisAlignment: CrossAxisAlignment.start,
  //                                   children: <Widget>[
  //                                     Text(widget.name, style: TextStyle(fontSize: 16),),
  //                                     SizedBox(height: 6,),
  //                                     Text(data[index].messageContent as String),
  //                                   ],
  //                                 ),
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                       // Text(conversations.processTimestamp(data[index].timeStamp), style: TextStyle(fontSize: 12, fontWeight: widget.isMessageRead == 0 ? FontWeight.bold : FontWeight.normal),),
  //                     ],
  //                   ),
  //                 );
  //               }
  //           ),
  //           ));
  //         }
  //       }
  //   );
  }
}