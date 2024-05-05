import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/screens/login_signup_page.dart';
import '/screens/master.dart';

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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Home(userId: userCredential.user!.uid, idx: 0),
          ),
        );

      } on FirebaseAuthException catch (ex) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid email or password.'),
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
              SizedBox(height: 80),
              Image.asset(
                'assets/images/logo.png',
                width: 800, // Adjust width as needed
                height: 250, // Adjust height as needed
              ) ,
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
