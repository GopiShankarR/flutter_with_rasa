// ignore_for_file: unused_import

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_with_rasa/models/chatMessages.dart';
import '../utils/dbHelper.dart';

class ChatUsers {
  int? id;
  int? userId;
  String? username;
  String? password;
  String? contact;
  ChatUsers({this.id, this.userId, this.username, this.contact});

  Future<void> dbSave() async {
    id = await DBHelper().insertData('chat_users', {
      'userId': userId,
      'username': username,
      'password': password,
      'contact': contact,
    });
  }

  Future<List<ChatUsers>> queryWithId(int userId) async {
    List<ChatUsers> chatUsers = [];
    await Future.delayed(const Duration(seconds: 1));

    final List<Map<String, dynamic>> result = await DBHelper().query(
      'chat_users',
      where: 'userId = $userId'
    );
    for (var map in result) {
      ChatUsers chatUser = ChatUsers(
        userId: map['userId'], 
        username: map['username'], 
        contact: map['contact']
      );
      chatUsers.add(chatUser);
    }
    return chatUsers;
  }

  Future<int> queryWithName(String name) async {
    final List<Map<String, dynamic>> result = await DBHelper().query(
      'chat_users',
      where: 'username = "$name"'
    );
    if(result.isNotEmpty) {
      final int userId = result[0]['userId'];
      return userId;
    }
    return 0;
  }

  Future<String> getName(int userId) async {
    final List<Map<String, dynamic>> result = await DBHelper().query(
      'chat_users',
      where: 'userId = $userId',
    );
    if (result.isNotEmpty) {
      final String name = result[0]['username'];
      return name;
    }
    return '';
  }
}