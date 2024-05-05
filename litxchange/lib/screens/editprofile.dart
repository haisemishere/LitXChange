import 'dart:io';
import 'package:flutter/material.dart';
import 'package:litxchange/screens/master.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfilePage extends StatefulWidget {
  final String currentUsername;
  final String currentBio;
  final String currentCity;
  final String profilePictureUrl;
  final String userEmail;

  const EditProfilePage({
    Key? key,
    required this.currentUsername,
    required this.currentBio,
    required this.currentCity,
    required this.userEmail,
    required this.profilePictureUrl,
  }) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  late TextEditingController _cityController;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  String? _userName;

  @override
  void initState() {
    super.initState();
    _usernameController =
        TextEditingController(text: widget.currentUsername);
    _bioController = TextEditingController(text: widget.currentBio);
    _cityController = TextEditingController(text: widget.currentCity);
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final userId = user!.uid; // Get user UID

      setState(() {
        // Reset previous error messages
        _userName = null;
      });

      if ((_usernameController.text.trim()).isEmpty) {
        setState(() {
          _userName = 'User name cannot be empty';
        });
        return;
      }

      // Upload profile picture to Firebase Storage if a new one is selected
      String imageUrl = widget.profilePictureUrl; // Default to existing URL
      if (_profileImage != null) {
        final storageRef =
        FirebaseStorage.instance.ref().child('profile_pictures/$userId.png');
        final uploadTask = storageRef.putFile(_profileImage!);
        imageUrl = await uploadTask.then((snapshot) async {
          return await snapshot.ref.getDownloadURL();
        });
      }

      // Update profile data in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({
        'userName': _usernameController.text.trim(),
        'bio': _bioController.text.trim(),
        'city': _cityController.text.trim(),
        'profilePictureUrl': imageUrl,
      });
    } catch (error) {
      print('Error uploading profile: $error');
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
              child: Text("Change Profile Picture",
                style: TextStyle(
                  color: Color(0xFF457a8b), // Change the color here
                ),),
            ),
            Text(
              'Email: ${widget.userEmail}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text('Username', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                hintText: 'Enter Username',
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xFF457a8b),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xFF457a8b),
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.red,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xFF457a8b),
                  ),
                ),
                errorText: _userName,
              ),
            ),
            SizedBox(height: 20),
            Text('Bio', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            TextFormField(
              controller: _bioController,
              decoration: InputDecoration(
                hintText: 'Enter a short description about yourself',
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xFF457a8b),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xFF457a8b),
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.red,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xFF457a8b),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text('City', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            TextFormField(
              controller: _cityController,
              decoration: InputDecoration(
                hintText: 'Enter your city',
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xFF457a8b),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xFF457a8b),
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.red,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xFF457a8b),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
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
            child:ElevatedButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                final userId = user!.uid;
                await _uploadProfile();
                Navigator.pop(context); // Pop the EditProfilePage
                Navigator.pushReplacement( // Replace the current route with the Home widget
                  context,
                  MaterialPageRoute(
                    builder: (context) => Home(userId: userId, idx: 4),
                  ),
                );
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
