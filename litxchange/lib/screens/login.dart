import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/screens/login_signup_page.dart';
import '/screens/createuserprofile.dart';
import '/screens/master.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _loginUser() async {
    if (_formKey.currentState!.validate()) {
      // If form is valid, proceed with login
      try {
        String email = _emailController.text.trim();
        String password = _passwordController.text.trim();
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
        // If login successful, navigate to Home with user ID
        Navigator.push(context, MaterialPageRoute(builder: (context) => Home(userId: userCredential.user!.uid)));
      } on FirebaseAuthException catch (ex) {
        // Display error message for invalid credentials
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Login Failed'),
            content: Text('Invalid email or password.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
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
              Image.asset(
                'assets/images/logo.png'
                    , // Adjust the asset path as per your project structure
                width: 800, // Adjust width as needed
                height: 250, // Adjust height as needed
              ) ,
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                margin: EdgeInsets.only(top: 0), // Adjust the top margin as needed
                child: Center(
                  child: Text(
                    "Login",
                    style: TextStyle(
                      color: Color.fromRGBO(69, 122, 139, 1.0),
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Times New Roman', // Set font family to Times New Roman
                      letterSpacing: 1.5, // Optional: Adjust letter spacing
                      shadows: [
                        Shadow(
                          color: Colors.grey.withOpacity(0.5),
                          offset: Offset(2, 2),
                          blurRadius: 3,
                        ),
                      ], // Optional: Add text shadow
                    ),
                  ),
                ),
              ),
            ),



              Padding(
                padding: EdgeInsets.all(40.0),
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color:  Color.fromRGBO(173, 216, 230, 1),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:  Color.fromRGBO(173, 216, 230, 1),
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
                                border: Border(
                                  bottom: BorderSide(
                                    color:  Color.fromRGBO(173, 216, 230, 1),
                                  ),
                                ),
                              ),
                              child: TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  labelText: 'Email',
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter an email';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  labelText: 'Password',
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a password';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    Container(
                      height: 50,
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
                        onPressed: _loginUser,
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF457a8b)), // Set background color to blue
                          foregroundColor:  MaterialStateProperty.all<Color>(Color.fromRGBO(255, 255, 255, 1.0)
                          ), // Add other desired styling properties here
                        ),
                        child: const Text('Login'),
                      ),


                    ),
                    SizedBox(height: 70),

                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginSignupPage(),
                          ),
                        );
                      },
                      child: Text(
                        'Don\'t have an account? Sign Up',
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
