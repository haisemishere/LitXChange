import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Existing sign in anonymously method
  Future signInAnon() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User? user = result.user;
      if (user != null) {
        print(user.uid);
      } else {
        print('Anonymous sign-in failed');
      }
      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Function to send sign-in link to email
  Future<void> sendSignInLinkToEmail(String email, ActionCodeSettings settings) async {
    try {
      return await _auth.sendSignInLinkToEmail(email: email, actionCodeSettings: settings);
    } catch (e) {
      print("Error sending sign-in link: ${e.toString()}");
      return null;
    }
  }

  // Function to sign in with the email link
  Future<UserCredential?> signInWithEmailLink(String email, String link) async {
    try {
      return await _auth.signInWithEmailLink(email: email, emailLink: link);
    } catch (e) {
      print("Error signing in with email link: ${e.toString()}");
      return null;
    }
  }

  Future<User?> signUpWithEmailAndPassword(String email, String password) async {
    final UserCredential result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }
}
