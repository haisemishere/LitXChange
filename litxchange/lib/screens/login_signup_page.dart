import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:litxchange/services/auth.dart'; // Update this import based on your project structure

class LoginSignupPage extends StatefulWidget {
  @override
  _LoginSignupPageState createState() => _LoginSignupPageState();
}

class _LoginSignupPageState extends State<LoginSignupPage> {
  final TextEditingController _emailController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in with Email Link')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            ElevatedButton(
              onPressed: () async {
                  // Specify your ActionCodeSettings
                  ActionCodeSettings settings = ActionCodeSettings(
                  url: 'https://www.litx.com/finishSignUp?cartId=1234',
                  handleCodeInApp: true,
                  androidPackageName: 'com.litx.litxchange',
                  androidInstallApp: true,
                  androidMinimumVersion: '12',
                );
                await _authService.sendSignInLinkToEmail(_emailController.text.trim(), settings);
                // Inform the user to check their email
              },
              child: const Text('Send Sign-In Link'),
            ),
          ],
        ),
      ),
    );
  }
}
