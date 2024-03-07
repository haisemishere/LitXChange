import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AddPage(),
    );
  }
}

class AddPage extends StatefulWidget {
  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final TextEditingController _bookNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _genreController = TextEditingController();
  File? _image;

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path); // Convert PickedFile to File
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Post'),
      ),
      body: SingleChildScrollView( // Make the content scrollable
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Book Name',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextFormField(
              controller: _bookNameController,
              decoration: InputDecoration(
                hintText: 'Enter the book name',
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Description',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter a description',
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Genre',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextFormField(
              controller: _genreController,
              decoration: InputDecoration(
                hintText: 'Enter the genre',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getImage,
              child: Text('Pick Image'),
            ),
            SizedBox(height: 20),
            _image != null
                ? Container(
              // Constrain the size of the image
              height: 200, // Set a fixed height for the image
              child: Image.file(_image!, fit: BoxFit.cover), // Adjust the fit as needed
            )
                : SizedBox(height: 2, width: 2),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Validate and save the form data
                _savePost();
              },
              child: Text('Post'),
            ),
          ],
        ),
      ),
    );
  }

  void _savePost() async
  {
    String bookName = _bookNameController.text.trim();
    String description = _descriptionController.text.trim();
    String genre = _genreController.text.trim();

    // Initialize imageUrl as null.
    String? imageUrl;

    try {
      if (_image != null) {
        final storageRef = FirebaseStorage.instance.ref().child('images/${DateTime.now()}.png');
        final uploadTask = storageRef.putFile(_image!);

        // Await for the upload to complete and then get the download URL.
        await uploadTask;
        imageUrl = await storageRef.getDownloadURL();
      }

      // Proceed to save the post with or without an imageUrl.
      await FirebaseFirestore.instance.collection('posts').add({
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'bookName': bookName,
        'description': description,
        'genre': genre,
        'date': DateTime.now(),
        'imageUrl': imageUrl ?? "", // Use the imageUrl if available; otherwise, use an empty string.
      });

      // Show a success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Post Successful'),
          content: Text('Post Added successfully'),
          actions: [
            TextButton(
              onPressed: () {
                _bookNameController.clear();
                _descriptionController.clear();
                _genreController.clear();
                setState(() {
                  _image = null; // Reset the image
                });
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (error) {
      // Show an error dialog if anything goes wrong during the upload or Firestore save process.
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Post Failed'),
          content: Text('Unable to add this post. Error: $error'),
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
      print("Error adding post: $error");
    }
    // Assuming you have a Post model class
    // This part of the code depends on how you've set up Firestore data model
    // and might require adjustments based on your Firestore collection structure
    FirebaseFirestore.instance.collection('posts').add({
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'bookName': bookName,
      'description': description,
      'genre': genre,
      'date': DateTime.now(),
      'imageUrl': imageUrl, // Store the image URL in Firestore
    }).then((value) => showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Post Successful'),
        content: Text('Post Added successfully'),
        actions: [
          TextButton(
            onPressed: () {
              _bookNameController.clear();
              _descriptionController.clear();
              _genreController.clear();
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    )).catchError((error) => showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Post Failed'),
        content: Text('Unable to add this post'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    ));
  }
}
