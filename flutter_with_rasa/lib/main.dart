import 'package:flutter/material.dart';
import 'package:flutter_with_rasa/models/socketProvider.dart';
import 'package:flutter_with_rasa/views/loginPage.dart';

const url = "http://192.168.86.239:8080";

void main() async {
  final socketProvider = SocketProvider();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login Page',
      home: Scaffold(
        body: FutureBuilder(
          future: socketProvider.connectToServer(url),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return LoginPage(socketProvider);
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      )
    )
  );
}
