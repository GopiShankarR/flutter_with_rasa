import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketProvider extends ChangeNotifier {
  io.Socket? _socket;

  io.Socket? get socket => _socket;

  Future<void> connectToServer(String serverURL) async {
    await connect(serverURL);
  }

  Future<void> connect(String url) async {
    try {
      _socket = io.io(url, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
      });

      _socket?.on('connect', (_) {
        print('Socket connected');
        notifyListeners();
      });

      _socket?.on('disconnect', (_) {
        print('Socket disconnected');
      });
    } catch (error) {
      print('Error connecting to socket: $error');
    }
  }

  void disconnect() {
    _socket?.disconnect();
  }

  @override
  void dispose() {
    _socket?.disconnect();
    super.dispose();
  }

  void emit(String s, Map<String, String?> newUser) {}
}