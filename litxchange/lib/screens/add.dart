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
  final TextEditingController _authorNameController = TextEditingController();
  String _selectedCondition = 'New'; // Default selected condition
  String _selectedGenre = 'Fiction'; // Default selected genre
  File? _image;

  final List<String> _conditionItems = ['New', 'Like New', 'Very Good', 'Good', 'Acceptable'];

  final List<String> _genreItems = [
    'Fiction',
    'Non-fiction',
    'Mystery',
    'Thriller',
    'Science Fiction (Sci-Fi)',
    'Fantasy',
    'Romance',
    'Historical Fiction',
    'Horror',
    'Adventure',
    'Crime',
    'Biography',
    'Autobiography',
    'Memoir',
    'Young Adult (YA)',
    "Children's",
    'Comedy',
    'Satire',
    'Poetry',
    'Drama',
    'Self-help',
    'Business',
    'Travel',
    'Science',
    'Philosophy',
    'Psychology',
    'Religion/Spirituality',
    'Cookbooks',
    'Art/Photography',
    'Graphic Novels/Comics',
    'Music',
    'Sports',
    'Health/Fitness',
    'Education',
    'Technology',
    'Parenting/Family',
    'LGBTQ+',
    'Military/War',
    'Supernatural/Paranormal',
    'Western',
    'Urban',
    'Environmental',
    'Dystopian',
    'Utopian',
    'Post-Apocalyptic',
    'Steampunk',
    'Cyberpunk',
    'Gothic',
    'Bildungsroman (Coming-of-age)',
    'Experimental/Avant-Garde',
  ];

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
        automaticallyImplyLeading: false,
        title: Text('New Post'),
      ),
      body: SingleChildScrollView( // Wrap the entire content with SingleChildScrollView
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Book Name',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _bookNameController,
                decoration: InputDecoration(
                  hintText: 'Enter the book name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Author',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _authorNameController,
                decoration: InputDecoration(
                  hintText: 'Enter the Author Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Book Condition',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCondition,
                onChanged: (newValue) {
                  setState(() {
                    _selectedCondition = newValue!;
                  });
                },
                items: _conditionItems.map((condition) {
                  return DropdownMenuItem<String>(
                    value: condition,
                    child: Text(condition),
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
              Text(
                'Genre',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedGenre,
                onChanged: (newValue) {
                  setState(() {
                    _selectedGenre = newValue!;
                  });
                },
                items: _genreItems.map((genre) {
                  return DropdownMenuItem<String>(
                    value: genre,
                    child: Text(genre),
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _getImage,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Color(0xFF457a8b), // Text color
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Button padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Button border radius
                  ),
                  elevation: 3, // Button shadow
                ),
                child: Text(
                  'Pick Image',
                  style: TextStyle(fontSize: 16), // Button text style
                ),
              ),
              SizedBox(height: 16),
              _image != null
                  ? Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  image: DecorationImage(
                    image: FileImage(_image!),
                    fit: BoxFit.cover,
                  ),
                ),
              )
                  : SizedBox.shrink(),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _savePost();
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Color(0xFF457a8b), // Text color
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Button padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Button border radius
                  ),
                  elevation: 3, // Button shadow
                ),
                child: Text(
                  'Post',
                  style: TextStyle(fontSize: 16), // Button text style
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _savePost() async {
    String bookName = _bookNameController.text.trim();
    String authorName = _authorNameController.text.trim();
    String condition = _selectedCondition;
    String genre = _selectedGenre;
    String? imageUrl;

    try {
      if (_image != null) {
        final storageRef = FirebaseStorage.instance.ref().child('images/${DateTime.now()}.png');
        final uploadTask = storageRef.putFile(_image!);
        await uploadTask;
        imageUrl = await storageRef.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('posts').add({
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'bookName': bookName,
        'authorName': authorName,
        'condition': condition,
        'genre': genre,
        'date': DateTime.now(),
        'imageUrl': imageUrl ?? '',
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Post Successful'),
          content: Text('Post Added successfully'),
          actions: [
            TextButton(
              onPressed: () {
                _bookNameController.clear();
                _authorNameController.clear();
                setState(() {
                  _selectedCondition = _conditionItems[0];
                  _selectedGenre = _genreItems[0];
                  _image = null;
                });
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (error) {
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
  }
}


