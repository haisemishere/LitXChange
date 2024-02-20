import 'package:flutter/material.dart';
import 'package:litxchange/services/auth.dart'; // Adjust import based on your project structure
import 'package:firebase_auth/firebase_auth.dart';

class LoginSignupPage extends StatefulWidget {
  @override
  _LoginSignupPageState createState() => _LoginSignupPageState();
}

class _LoginSignupPageState extends State<LoginSignupPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _registerUser() async {
    if (_formKey.currentState!.validate()) {
      // Check if passwords match
      if (_passwordController.text == _confirmPasswordController.text) {
        try {
          // Sign up with email and password
          User? user = await _authService.signUpWithEmailAndPassword(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );

          if (user != null) {
            print("User created: ${user.uid}");
            // Send email verification link
            await user.sendEmailVerification();
            print("Verification email sent.");
            // Navigate to your app's home screen or show a success message
          }
        } on FirebaseAuthException catch (e) {
          // Handle errors, such as email already in use or weak password
          print("Error: ${e.code}");
          print(e.message);
        }
      } else {
        // Handle password confirmation mismatch
        print("Passwords do not match.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) => value!.isEmpty ? 'Please enter an email' : null,
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (value) => value!.length < 6 ? 'Password must be at least 6 characters' : null,
              ),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Confirm Password'),
                validator: (value) => value != _passwordController.text ? 'Passwords do not match' : null,
              ),
              ElevatedButton(
                onPressed: _registerUser,
                child: const Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
