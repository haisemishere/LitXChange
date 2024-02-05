import 'package:firebase_auth/firebase_auth.dart';

class AuthService{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  //sign in anon
Future signInAnon() async {
  try{
    UserCredential result = await _auth.signInAnonymously();
    User? user = result.user;

// Now, you can use 'user' with null-aware operations
    if (user != null) {
      // Do something with 'user'
      print(user.uid);
    } else {
      // Handle the case when 'user' is null
      print('Anonymous sign-in failed');
    }
     return user;
    }
    catch(e)
    {
      print(e.toString());
      return null;
    }
}

}