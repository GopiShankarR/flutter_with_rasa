import 'package:flutter_with_rasa/models/chatUsers.dart';
import '../models/chatMessages.dart';
import '../utils/dbHelper.dart';

class Chat {
  final int correspondentId;
  final String correspondentName;
  final List<ChatMessages> messages;

  Chat({
    required this.correspondentId,
    required this.correspondentName,
    required this.messages,
  });
}

class ChatService {
  //  late io.Socket _socket;

  //  ChatService() {
  //   _initializeSocket();
  //  }

  //  void _initializeSocket() {
  //   _socket = io.io('YOUR_SOCKET_IO_SERVER_URL');

  //   _socket.on('new_message', (data) {
  //     print("new message: $data");
  //   });

  //   _socket.on('user_connected', (data) {
  //     print("user connected");
  //   });

  //   _socket.on('user_disconnected', (data) {
  //     print("user disconnected");
  //   });

  //   _socket.connect();
  // }

  Future<List<ChatMessages>> getMessagesForUser(int userId, int receiverId) async {
    final List<Map<String, dynamic>> result = await DBHelper().customQuery('''
      SELECT cm.*, cuSender.username AS senderName, cuReceiver.username AS receiverName
      FROM chat_messages cm
      INNER JOIN chat_users cuSender ON cm.senderId = cuSender.userId
      INNER JOIN chat_users cuReceiver ON cm.receiverId = cuReceiver.userId
      WHERE (cm.senderId = $userId AND cm.receiverId = $receiverId)
        OR (cm.senderId = $receiverId AND cm.receiverId = $userId)
      ORDER BY cm.timeStamp ASC
    ''');

    List<ChatMessages> messages = result.map<ChatMessages>((map) => ChatMessages.fromMap(map)).toList();

    List<ChatMessages> userMessages = messages.where((message) => message.senderId == userId || message.receiverId == userId).toList();

    return userMessages;
  }

  Future<List<Chat>> getChatsForUser(int userId, int receiverId) async {
    List<ChatMessages> messages = await getMessagesForUser(userId, receiverId);
    Map<int, List<ChatMessages>> messagesByCorrespondent = {};

    messages.forEach((message) {
      int correspondentId = (message.senderId != userId) ? message.senderId! : message.receiverId!;
      if (!messagesByCorrespondent.containsKey(correspondentId)) {
        messagesByCorrespondent[correspondentId] = [];
      }
      messagesByCorrespondent[correspondentId]!.add(message);
    });

    Map<int, String> correspondentNames = {};
    for (int correspondentId in messagesByCorrespondent.keys) {
      String correspondentName = await ChatUsers().getName(correspondentId);
      correspondentNames[correspondentId] = correspondentName;
    }

    List<Chat> chats = [];
    messagesByCorrespondent.forEach((correspondentId, messages) {
      messages.sort((a, b) => a.timeStamp!.compareTo(b.timeStamp!));
      String correspondentName = correspondentNames[correspondentId] ?? 'Unknown';
      Chat chat = Chat(
        correspondentId: correspondentId,
        correspondentName: correspondentName,
        messages: messages,
      );
      chats.add(chat);
    });

    return chats;
  }
}