import 'package:flutter/material.dart';
import '/screens/master.dart';
import '/screens/login.dart';
import '/screens/createuserprofile.dart';
import '/services/auth.dart';
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
  bool _verificationEmailSent = false;

  Future<bool> isEmailVerified() async {
    User? user = FirebaseAuth.instance.currentUser;
    await user?.reload();
    return user?.emailVerified ?? false;
  }

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

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Verification email sent. Please verify your email.'),
              ),
            );

            setState(() {
              _verificationEmailSent = true;
            });

            if (await isEmailVerified()) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ProfileCreationPage()),
              );
            } else {
              print("Email not verified. Please verify your email.");
            }
          }
        } on FirebaseAuthException catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Account with this email already exists'),
            ),
          );
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
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: <Widget>[
              SizedBox(height: 80),
              Image.asset(
                'assets/images/logo.png',
                width: 800,
                height: 250,
              ),

              Padding(
                padding: EdgeInsets.all(30.0),
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Color.fromRGBO(173, 216, 230, 1)),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(173, 216, 230, 1),
                            blurRadius: 20.0,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: Color.fromRGBO(173, 216, 230, 1))),
                              ),
                              child: TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  labelStyle: TextStyle(color: Color(0xFF457a8b)),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Color(0xFF457a8b)), // Change border color when focused
                                  ),
                                  labelText: 'Email',
                                ),
                                cursorColor:Color(0xFF457a8b),
                                validator: (value) =>
                                value!.isEmpty ? 'Please enter an email' : null,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  labelStyle: TextStyle(color: Color(0xFF457a8b)),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Color(0xFF457a8b)), // Change border color when focused
                                  ),
                                  labelText: 'Password',
                                ),
                                cursorColor:Color(0xFF457a8b),
                                validator: (value) =>
                                value!.length < 6 ? 'Password must be at least 6 characters' : null,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: true,
                                decoration: InputDecoration(labelText: 'Confirm Password',
                                  labelStyle: TextStyle(color: Color(0xFF457a8b)),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Color(0xFF457a8b)), // Change border color when focused
                                  ),),
                                cursorColor:Color(0xFF457a8b),
                                validator: (value) =>
                                value != _passwordController.text ? 'Passwords do not match' : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                    // Conditional button based on verification status
                    if (!_verificationEmailSent)
                      Container(
                        height: 60,
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            colors: [
                              Color.fromRGBO(69, 122, 139, 1.0),
                              Color.fromRGBO(69, 122, 139, 1.0),
                            ],
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: _registerUser,
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF457a8b)),
                            foregroundColor: MaterialStateProperty.all<Color>(Color.fromRGBO(255, 255, 255, 1.0)),
                          ),
                          child: const Text('Sign Up'),
                        ),
                      ),
                    if (_verificationEmailSent)
                      Container(
                        height: 60,
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            colors: [
                              Color.fromRGBO(69, 122, 139, 1.0),
                              Color.fromRGBO(69, 122, 139, 1.0),
                            ],
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                            if (await isEmailVerified()) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => ProfileCreationPage()),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Email not verified. Please verify your email.'),
                                ),
                              );
                            }
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF457a8b)),
                            foregroundColor: MaterialStateProperty.all<Color>(Color.fromRGBO(255, 255, 255, 1.0)),
                          ),
                          child: const Text('Continue'),
                        ),
                      ),
                    SizedBox(height: 70,),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Login(),
                          ),
                        );
                      },
                      child: Text(
                        'Already have an account? Login',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
