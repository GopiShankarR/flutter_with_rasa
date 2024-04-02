import 'package:flutter/material.dart';
import 'package:flutter_with_rasa/views/loginPage.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Login Page',
    home: Scaffold(
      body: LoginPage(),
    )
  ));
}
