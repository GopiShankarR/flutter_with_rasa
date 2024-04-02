// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unused_local_variable, use_build_context_synchronously, unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:flutter_with_rasa/models/chatUsers.dart';
import 'package:flutter_with_rasa/views/homeScreen.dart';
import 'dart:math';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

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
    int response = await ChatUsers().queryWithName(name);
    int userId = 0;

    if(response != 0) {
      userId = response;
      if (!mounted) return;
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => HomeScreen(userId),
        ));
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Login Failed'),
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
  }

  Future<void> _register(BuildContext context) async {
    final username = usernameController.text;
    final contact = contactController.text;
    final password = passwordController.text;
    
    Random random = Random();

    if (!mounted) return;

    final newUser = ChatUsers(
      userId: random.nextInt(100),
      username: username,
      contact: contact,
    );

    newUser.dbSave();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => HomeScreen(newUser.userId as int),
      )
    );
  }
}