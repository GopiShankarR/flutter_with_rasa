// ignore_for_file: file_names, unused_local_variable, unused_import

import 'dart:convert';

import '../utils/dbHelper.dart';
import 'package:intl/intl.dart';

class ChatMessages {
  int? messageId;
  int? senderId;
  int? receiverId;
  String? messageContent;
  DateTime? timeStamp;
  ChatMessages({this.messageId, this.senderId, this.receiverId, this.messageContent, this.timeStamp});

  Future<void> dbSave() async {
    if (senderId == receiverId) {
      return; 
    }
    var dt = timeStamp;
    String dtStr = dt!.toIso8601String();

    messageId = await DBHelper().insertData('chat_messages', {
      'senderId': senderId,
      'receiverId': receiverId,
      'messageContent': messageContent,
      'timeStamp': dtStr,
    });
  }

  Future<void> dbUpdate() async {
    await DBHelper().updateData('user_data', {
      'messageContent': messageContent
    }, messageId!);
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

  Future<List<ChatMessages>> queryData(int senderId) async {
    List<ChatMessages> chatMessages = [];

    final List<Map<String, dynamic>> result = await DBHelper().query(
      'chat_messages',
      where: 'senderid = $senderId'
    );

    for (var map in result) {
      ChatMessages chatMessage = ChatMessages(
        senderId: map['senderId'], 
        receiverId: map['receiverId'], 
        messageContent: map['messageContent'],
        timeStamp: DateTime.parse(map['timeStamp']),
      );
      chatMessages.add(chatMessage);
    }
    return chatMessages;
  }

Future<List<Map<String, dynamic>>> getLastMessages(int userId) async {
  final dbHelper = DBHelper();
  final List<Map<String, dynamic>> result = await dbHelper.customQuery('''
    SELECT cu.username as username, cm.messageContent as messageContent, cm.timeStamp as timeStamp, cm.receiverId as receiverId
    FROM chat_users cu
    INNER JOIN (
        SELECT CASE
                   WHEN senderId = $userId THEN receiverId
                   ELSE senderId
               END AS userId,
               MAX(messageId) AS lastMessageId
        FROM chat_messages
        WHERE senderId = $userId OR receiverId = $userId
        GROUP BY CASE
                     WHEN senderId = $userId THEN receiverId
                     ELSE senderId
                 END
    ) AS latestMessages ON cu.userId = latestMessages.userId
    INNER JOIN chat_messages cm ON (cu.userId = cm.senderId OR cu.userId = cm.receiverId)
                                  AND cm.messageId = latestMessages.lastMessageId
    ''');

    return result;
  }

  factory ChatMessages.fromMap(Map<String, dynamic> map) {
    return ChatMessages(
      messageId: map['messageId'],
      senderId: map['senderId'],
      receiverId: map['receiverId'],
      messageContent: map['messageContent'],
      timeStamp: DateTime.parse(map['timeStamp']),
    );
  }
}

