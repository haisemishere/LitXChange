import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:litxchange/screens/login.dart';
import 'package:litxchange/screens/profile.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
class EditProfilePage extends StatefulWidget {
  final String currentUsername;
  final String currentBio;
  final String currentCity;
  final String profilePictureUrl;
  final Function(String, String, String, String) onUpdate;
  final String userEmail;

  const EditProfilePage({
    Key? key,
    required this.currentUsername,
    required this.currentBio,
    required this.currentCity,
    required this.onUpdate,
    required this.userEmail,
    required this.profilePictureUrl,// Pass user email to EditProfilePage
  }): super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  late TextEditingController _cityController;
  String _userEmail = '';
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    _fetchUserEmail();
    super.initState();
    _usernameController =
        TextEditingController(text: widget.currentUsername);
    _bioController = TextEditingController(text: widget.currentBio);
    _cityController = TextEditingController(text: widget.currentCity);
  }

  Future<void> _fetchUserEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userEmail = user.email ?? '';
      });
    }
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
        title: Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
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
            Text(
              'Email: $_userEmail',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text('Username', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                hintText: 'Enter Username',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Text('Bio', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            TextFormField(
              controller: _bioController,
              decoration: InputDecoration(
                hintText: 'Enter a short description about yourself',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Text('City', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            TextFormField(
              controller: _cityController,
              decoration: InputDecoration(
                hintText: 'Enter your city',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async{
                await _uploadImage();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Color(0xFF457a8b), // Text color
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Button padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Button border radius
                ),
                elevation: 3, // Button shadow
              ),
              child: Text(
                'Save',
                style: TextStyle(fontSize: 16), // Button text style
              ),
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