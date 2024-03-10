import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:litxchange/screens/login.dart';

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
  String _profilePictureUrl = "https://via.placeholder.com/150";
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _firestore = FirebaseFirestore.instance;
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userId = user.uid;
      var userData = await _firestore.collection('users').doc(_userId).get();
      setState(() {
        _username = userData.data()?['userName'] ?? '';
        _bio = userData.data()?['bio'] ?? '';
        _city = userData.data()?['city'] ?? '';
        _profilePictureUrl = userData.data()?['profilePictureUrl'] ?? "https://via.placeholder.com/150";
        _userEmail = user.email ?? '';
      });
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
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfilePage(
              currentUsername: _username,
              currentBio: _bio,
              currentCity: _city,
              currentEmail: _userEmail,
              profilePictureUrl: _profilePictureUrl,
              onUpdate: (newUsername, newBio, newCity, newProfilePictureUrl) {
                setState(() {
                  _username = newUsername;
                  _bio = newBio;
                  _city = newCity;
                  _profilePictureUrl = newProfilePictureUrl;
                });
                _saveUserData();
              },
            ))),
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Login())),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(_profilePictureUrl),
              ),
              SizedBox(height: 20),
              Text(_username, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text(_bio, style: TextStyle(fontSize: 16)),
              SizedBox(height: 10),
              Text(_city, style: TextStyle(fontSize: 16)),
              // Add more widgets here for user posts and other info
            ],
          ),
        ),
      ),
    );
  }

  void _saveUserData() async {
    await _firestore.collection('users').doc(_userId).update({
      'userName': _username,
      'bio': _bio,
      'city': _city,
      'profilePictureUrl': _profilePictureUrl,
    });
  }
}

// Modify the EditProfilePage to include the functionality for updating profile pictures
class EditProfilePage extends StatefulWidget {
  final String currentUsername;
  final String currentBio;
  final String currentCity;
  final String currentEmail;
  final String profilePictureUrl;
  final Function(String, String, String, String) onUpdate;

  const EditProfilePage({
    Key? key,
    required this.currentUsername,
    required this.currentBio,
    required this.currentCity,
    required this.currentEmail,
    required this.profilePictureUrl,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _usernameController.text = widget.currentUsername;
    _bioController.text = widget.currentBio;
    _cityController.text = widget.currentCity;
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_profileImage != null) {
      String fileName = 'profile_${widget.currentUsername}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final firebaseStorageRef = FirebaseStorage.instance.ref().child('profile_images/$fileName');
      await firebaseStorageRef.putFile(_profileImage!);
      final downloadUrl = await firebaseStorageRef.getDownloadURL();
      widget.onUpdate(_usernameController.text, _bioController.text, _cityController.text, downloadUrl);
    } else {
      widget.onUpdate(_usernameController.text, _bioController.text, _cityController.text, widget.profilePictureUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_profileImage != null)
                CircleAvatar(
                  backgroundImage: FileImage(_profileImage!),
                  radius: 50,
                ),
              TextButton(
                onPressed: _pickImage,
                child: Text("Change Profile Picture"),
              ),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: "Username"),
              ),
              TextField(
                controller: _bioController,
                decoration: InputDecoration(labelText: "Bio"),
              ),
              TextField(
                controller: _cityController,
                decoration: InputDecoration(labelText: "City"),
              ),
              ElevatedButton(
                onPressed: () async {
                  await _uploadImage();
                  Navigator.pop(context);
                },
                child: Text("Save Changes"),
              ),
            ],
          ),
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
