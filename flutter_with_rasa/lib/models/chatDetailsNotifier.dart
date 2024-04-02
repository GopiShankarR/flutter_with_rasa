import 'package:flutter/material.dart';
import 'package:flutter_with_rasa/models/chatMessages.dart';
import 'package:flutter_with_rasa/models/chatService.dart';

class ChatDetailsNotifier extends ChangeNotifier {
  late List<Chat> _chats;
  final int userId;
  final int receiverId;

  ChatDetailsNotifier(this.userId, this.receiverId) {
    _chats = [];
    fetchChats();
  }

  List<Chat> get chats => _chats;

  Future<void> fetchChats() async {
    _chats = await ChatService().getChatsForUser(userId, receiverId);
  }

  Future<void> sendMessage(String messageContent) async {
    if (messageContent.isNotEmpty) {
      await ChatMessages(
        senderId: userId,
        receiverId: receiverId,
        messageContent: messageContent,
        timeStamp: DateTime.now(),
      ).dbSave(); 

      await fetchChats();
      notifyListeners();
    }
  } 
}