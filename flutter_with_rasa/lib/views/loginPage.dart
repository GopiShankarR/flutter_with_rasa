// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unused_local_variable, use_build_context_synchronously, unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:flutter_with_rasa/views/homeScreen.dart';
import '../models/socketProvider.dart';
import 'dart:math';

class LoginPage extends StatefulWidget {
  final SocketProvider? _socket;
  const LoginPage(this._socket, {super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController contactController = TextEditingController();

  bool isRegistering = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(90, 23, 238, 0.4),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 40,),
              Text('Hello!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
              SizedBox(height: 10,),
              Text('Please sign in to continue', style: TextStyle(fontSize: 20),),
              SizedBox(height: 15,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: TextField(
                        controller: usernameController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Username',
                        ),
                      )
                    )
                  )
                ),
                SizedBox(height: 15,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Password',
                        ),
                      )
                    )
                  )
                ),
                SizedBox(height: 20,),
                if(isRegistering == true)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: TextField(
                          controller: contactController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Contact',
                          ),
                        )
                      )
                    )
                  ),
                SizedBox(height: 20,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: TextButton(
                        onPressed: () => isRegistering == true ? _register(context) : _login(context),
                        child: Text(
                          (isRegistering == true ? 'Submit' : 'Log In'), 
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          )
                        ),
                      ),
                    ),
                  ),
                ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if(!isRegistering)
                    Text(
                      'Not a member?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if(!isRegistering)
                    TextButton(
                      onPressed: () => _toggleRegisterState(),
                      child: Text(
                        ' Register Now', 
                        style: TextStyle(
                          color: Colors.blue[500], fontWeight: FontWeight.bold,
                        )
                      ),
                    ),
                ],
              )
            ],
          ),
        )
      )
    );
  }

  void _toggleRegisterState() {
    setState(() {
      isRegistering = !isRegistering;
    });
  }

  Future<void> _login(BuildContext context) async {
    final name = usernameController.text;
    final password = passwordController.text;
    final contact = contactController.text;
    final loginData = {'username': name, 'password': password, 'contact': contact};

    widget._socket?.socket?.emit('login', loginData);
    widget._socket?.socket?.on('login_response', (response) {
      if(response.runtimeType == double) {
        if (!mounted) return;
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (_) => HomeScreen(response, widget._socket),
          ));
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(response),
              content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('User might not be registered or the username and password may be incorrect. Try Again!'),
                ],
              ),
            ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),  
                ),
              ],
            );
          },
        );
      }
    });
  }

  Future<void> _register(BuildContext context) async {
    final username = usernameController.text;
    final contact = contactController.text;
    final password = passwordController.text;
    
    Random random = Random();

    final loginData = {'username': username, 'password': password, 'contact': contact};
    widget._socket?.socket?.emit('register', loginData);

    widget._socket?.socket?.on('register_response', (response) {
      if(response.runtimeType == double) {
        final userId = response;
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('User Registered Successfully'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (_) => HomeScreen(userId.toInt(), widget._socket),
                    ));
                  },
                  child: const Text('OK'),  
                ),
              ],
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (context) {
            final insertedId = response['userId'].toInt();
            return AlertDialog(
              title: Text(response['response'] as String),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (_) => HomeScreen(insertedId, widget._socket),
                    ));
                  },
                  child: const Text('OK'), 
                ),
              ],
            );
          },
        );
      }
    });
  }
}