import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/screens/master.dart';

class ProfileCreationPage extends StatefulWidget {
  @override
  _ProfileCreationPageState createState() => _ProfileCreationPageState();
}

class _ProfileCreationPageState extends State<ProfileCreationPage> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  File? _profilePicture;

  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _fetchUserEmail();
  }

  Future<void> _fetchUserEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userEmail = user.email ?? '';
      });
    }
  }

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _profilePicture = File(pickedFile.path); // Convert PickedFile to File
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _submitProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final userId = user!.uid; // Get user UID

      // Check if the user's profile already exists in Firestore
      final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
      final userDoc = await userRef.get();

      // Get the username entered by the user
      final userName = _userNameController.text.trim();

      // Upload profile picture to Firebase Storage
      String imageUrl = '';
      if (_profilePicture != null) {
        final storageRef = FirebaseStorage.instance.ref().child('profile_pictures/$userId.png');
        final uploadTask = storageRef.putFile(_profilePicture!);
        await uploadTask.whenComplete(() async {
          imageUrl = await storageRef.getDownloadURL();
        });
      }

      // If the user's profile already exists, update it
      if (userDoc.exists) {
        await userRef.update({
          'userName': userName,
          'city': _cityController.text.trim(),
          'bio': _bioController.text.trim(),
          'profilePictureUrl': imageUrl, // Add profile picture URL to update
        });
      } else {
        // If the user's profile doesn't exist, create a new one
        await userRef.set({
          'uid': userId,
          'userName': userName,
          'city': _cityController.text.trim(),
          'bio': _bioController.text.trim(),
          'profilePictureUrl': imageUrl, // Add profile picture URL for new profile
        });
      }

      // Navigate to Home page with user ID parameter
      Navigator.push(context, MaterialPageRoute(builder: (context) => Home(userId: userId)));
    } catch (error) {
      print('Error creating/updating profile: $error');
      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Profile Creation Failed'),
          content: Text('Invalid information'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Create Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Email: $_userEmail',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text('Username', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              TextFormField(
                controller: _userNameController,
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
                onPressed: _getImage,
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
                  'Select Profile Picture',
                  style: TextStyle(fontSize: 16), // Button text style
                ),
              ),
              SizedBox(height: 16),
              _profilePicture != null ? Image.file(_profilePicture!) : SizedBox(),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitProfile,
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
      ),
    );
  }
}
