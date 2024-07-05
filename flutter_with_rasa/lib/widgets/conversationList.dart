// ignore_for_file: prefer_const_constructors, must_be_immutable, unrelated_type_equality_checks

import 'package:flutter/material.dart';
import '../models/socketProvider.dart';
import '../views/chatDetailsPage.dart';
import 'package:intl/intl.dart';

class ConversationList extends StatefulWidget {
  double userId;
  double receiverId;
  String name;
  String? messageContent;
  double conversationId;
  DateTime? timeStamp;
  final SocketProvider? _socket;
  ConversationList(this._socket, {super.key, required this.userId, required this.receiverId, required this.messageContent, required this.conversationId, required this.name, this.timeStamp,});

  @override
  State<ConversationList> createState() => _ConversationListState();
}

class _ConversationListState extends State<ConversationList> {

  @override
  void initState() {
    super.initState();
  }

   String processTimestamp(DateTime time) {
    final now = DateTime.now();
    final formatter = DateFormat('HH:mm');
    final dateFormatter = DateFormat('yyyy-MM-dd'); 
    final difference = now.difference(time);
    var formattedTime = '', formattedDate = '';
    if (difference.inHours < 24) {
      formattedTime = formatter.format(time);
      return formattedTime;
    } else {
      formattedDate = dateFormatter.format(time);
      return formattedDate;
    }
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
              processTimestamp(widget.timeStamp as DateTime),
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
          "",
          style: TextStyle(
            color: Colors.grey,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      onTap: () {
        widget._socket?.socket?.emit('get_conversation_id', { 'userId': widget.userId, 'receiverId': widget.receiverId });
        widget._socket?.socket?.on('return_conversation_id', (response) {
          widget.conversationId = response;
        });
        Navigator.push(
          context, MaterialPageRoute(
            builder: (context) {
              return ChatDetailsPage(widget._socket, widget.userId.toDouble(), widget.receiverId.toDouble(), widget.name, widget.conversationId);
            }
          )
        );
      },
    );
  }
}