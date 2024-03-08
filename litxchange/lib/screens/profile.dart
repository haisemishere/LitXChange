import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    home: ProfilePage(),
  ));
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late FirebaseFirestore _firestore;
  late String _userId;
  String _username = "";
  String _bio = "";
  String _city = "";

  @override
  void initState() {
    super.initState();
    _firestore = FirebaseFirestore.instance;
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _userId = user.uid;
        DocumentSnapshot userData =
        await _firestore.collection('users').doc(_userId).get();
        setState(() {
          _username = userData['userName'];
          _bio = userData['bio'];
          _city = userData['city'];
        });
      }
    } catch (error) {
      print("Error fetching user data: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfilePage(
                    currentUsername: _username,
                    currentBio: _bio,
                    currentCity: _city,
                    onUpdate: _updateUserData,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(
                    'https://via.placeholder.com/150'), // User profile image
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                _username, // User's username
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: Text(
                _bio, // User's bio
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: Text(
                _city, // User's city
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateUserData(String newUsername, String newBio, String newCity) {
    setState(() {
      _username = newUsername;
      _bio = newBio;
      _city = newCity;
    });
    _saveUserData();
  }

  void _saveUserData() async {
    try {
      await _firestore.collection('users').doc(_userId).set({
        'username': _username,
        'bio': _bio,
        'city': _city,
      });
      print('User data saved successfully');
    } catch (error) {
      print('Error saving user data: $error');
    }
  }
}

class EditProfilePage extends StatefulWidget {
  final String currentUsername;
  final String currentBio;
  final String currentCity;
  final Function(String, String, String) onUpdate;

  EditProfilePage({
    required this.currentUsername,
    required this.currentBio,
    required this.currentCity,
    required this.onUpdate,
  });

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  late TextEditingController _cityController;

  @override
  void initState() {
    super.initState();
    _usernameController =
        TextEditingController(text: widget.currentUsername);
    _bioController = TextEditingController(text: widget.currentBio);
    _cityController = TextEditingController(text: widget.currentCity);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Username'),
            TextFormField(
              controller: _usernameController,
            ),
            SizedBox(height: 20),
            Text('Bio'),
            TextFormField(
              controller: _bioController,
            ),
            SizedBox(height: 20),
            Text('City'),
            TextFormField(
              controller: _cityController,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                widget.onUpdate(
                  _usernameController.text,
                  _bioController.text,
                  _cityController.text,
                );
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    _cityController.dispose();
    super.dispose();
  }
}
