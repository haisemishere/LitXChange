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
            //if (user.emailVerified) {
              // Navigate to the home screen or show a success message
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ProfileCreationPage()),
              );
           // } else {
              // If email is not verified, you can show a message to the user
             // print("Email not verified. Please verify your email.");
            //}
          }
        } on FirebaseAuthException catch (e) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('SignUp Failed'),
              content: Text('Account with this email already exists'),
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
                      "Sign Up",
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
                  padding: EdgeInsets.all(30.0),
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color:  Color.fromRGBO(173, 216, 230, 1)),
                            boxShadow: [
                              BoxShadow(
                                  color:  Color.fromRGBO(173, 216, 230, 1),
                                  blurRadius: 20.0,
                                  offset: Offset(0, 10)
                              )
                            ]
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                    border: Border(bottom: BorderSide(color:   Color.fromRGBO(173, 216, 230, 1)))
                                ),
                                child: TextFormField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    labelText: 'Email',
                                  ),
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
                                    labelText: 'Password',
                                  ),
                                  validator: (value) => value!.length < 6
                                      ? 'Password must be at least 6 characters'
                                      : null,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: _confirmPasswordController,
                                  obscureText: true,
                                  decoration:
                                  InputDecoration(labelText: 'Confirm Password'),
                                  validator: (value) =>
                                  value != _passwordController.text
                                      ? 'Passwords do not match'
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 30,),
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(
                                colors: [
                                  Color.fromRGBO(69, 122, 139, 1.0),
                                  Color.fromRGBO(69, 122, 139, 1.0),
                                ]
                            )
                        ),
                        child: ElevatedButton(
                          onPressed: _registerUser,
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF457a8b)), // Set background color to blue
                            foregroundColor:  MaterialStateProperty.all<Color>(Color.fromRGBO(255, 255, 255, 1.0)
                            ), // Add other desired styling properties here
                          ),
                          child: const Text('Sign Up'),
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
        )
    );
  }
}
